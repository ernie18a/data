# FTNS Multi-Asset Correlation HUD

- url: https://www.tradingview.com/script/TVMSd5BD/
- type: indicator
- pine_id: PUB;cb3bf4a98a2b4691a48ee8b1beaf2cef
- version: 1.0

## Description

[b]Introduction[/b]
The FTNS Multi-Asset Correlation HUD is a highly sophisticated, real-time intermarket environment analyzer engineered for Pine Script v6. Inspired by the legendary "Bottomscan" tool from the classic daytradenet.com, this indicator allows traders to monitor up to 15 interrelated assets simultaneously and instantly gauge their collective macro impact on a target currency pair or financial instrument (ideally optimized for USD/JPY).

Unlike standard correlation tables that merely display raw price percentage changes, this HUD features a proprietary "Judgement Engine" that translates individual asset dynamics into directional pressures affecting your primary trading vehicle.



[b]The Core Innovation: The "Judgement" System[/b]
The heart of this indicator is the Judgement column. It does not simply show whether a correlated asset is moving up or down; it explicitly calculates how that specific movement influences your target instrument based on its predefined directional bias (Positive or Negative correlation).

* ▲▲ / ▲ (Bullish Pressure): Intermarket forces are acting to push the target instrument higher (e.g., Rising US10Y Yields or a surging Dollar Index for USD/JPY). Color-coded in bright green.
* ▼▼ / ▼ (Bearish Pressure): Intermarket forces are acting to drag the target instrument lower (e.g., A dropping Nikkei 225 triggering a risk-off Yen-buying anomaly). Color-coded in bright red.
* ■ (Neutral): Flatlined or no significant momentum change.

[b]💡 Real-World Example (USD/JPY Setup):[/b]
* If US 10-Year Yields (US10Y) fall, it exerts downward pressure on USD/JPY. The HUD instantly logs this asset and displays a red ▼ or ▼▼.
* If the Nikkei 225 (NI225) drops, historical correlation dictates a stronger Yen (risk-off Yen repatriation), resulting in downward pressure on USD/JPY. The HUD automatically interprets this market drop as a bearish factor for USD/JPY, flashing a red warning sign.



[b]Key Features[/b]

1. 15-Asset Intermarket Matrix
   Fully customizable tracking for up to 15 financial assets across different sectors (FX Pairs, Equities, Bond Yields, Commodities, or Crypto). Easily toggle visibility and set independent Positive (+) or Negative (-) correlation rules.
2. Bottomscan-Style Vector Symbols
   Employs highly legible classical vector symbols (`▲▲`, `▲`, `▼▼`, `▼`, `■`) to represent both the direction and velocity of intermarket cross-currents at a single glance.
3. **Adjustable "Strong Bias" Threshold**
   Tailor the exact Rate of Change (ROC%) required to trigger a strong trend warning. When an asset's ROC exceeds your custom threshold, the HUD automatically upgrades the vector to a dual symbol (`▲▲` or `▼▼`).
4. High-Congruence Macro Alert (Flash Gimmick)
   When a critical mass of monitored assets aligns seamlessly in the same directional bias (66.6% or 75%+ congruence), the top status bar dynamically shifts its state and flashes vivid colors to warn you of institutional macro-driven breakouts or high-probability trend continuations.
5. Modern Flat Design UI Layout
   Built with a borderless, shadowless flat design aesthetic. It sits perfectly into any dark or light trading setup without cluttering your screen or causing visual fatigue.
6. Status Line Parameter Hiding
   Leverages advanced Pine Script v6 properties (`display=display.none`) to completely hide all 45+ internal input variables from the top-left chart status line. Your workspace stays clean and pristine, showing only the script name while leaving settings fully customizable in the inputs menu.



[b]How to Use[/b]
1. Apply the indicator to your primary trading asset (e.g., USD/JPY).
2. Open the settings panel and load the symbols that fundamentally drive your target market (e.g., DXY, US10Y, EURUSD, NI225, XAUUSD).
3. Assign the mathematically correct correlation rule (`Positive` or `Negative`) for each secondary asset.
4. Adjust the KPI Timeframe (ROC) and Strong Bias Threshold (%) to match your trading style (Scalping, Day Trading, or Swing Trading).
5. Monitor the Master Status Bar for institutional flow alignment and use the Judgement matrix to avoid trading against the broader macroeconomic tide.

## Source Code

````pine
//@version=6
indicator("FTNS Multi-Asset Correlation HUD", overlay=true)

// ==========================================
// 1. HUD & KPI Settings
// ==========================================
gp_gen    = "HUD & KPI Settings"
tf_input  = input.timeframe("15", title="KPI Timeframe (ROC)", group=gp_gen, display=display.none)
roc_len   = input.int(14, title="ROC Length", group=gp_gen, display=display.none)
strong_th = input.float(0.10, title="Strong Bias Threshold (%)", minval=0.01, step=0.01, group=gp_gen, display=display.none)
tbl_pos   = input.string("Top Right", title="HUD Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=gp_gen, display=display.none)

// Helper function for table positioning
get_position(pos) =>
    switch pos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Global function for array pushing & bottomscan-style judgement evaluation
push_data(bool en, string tk, float roc, string co, float th, string[] tks, string[] j_txts, color[] j_cols) =>
    if en and tk != ""
        array.push(tks, tk)
        
        // 1. Evaluate Judgement Direction (Impact on USD/JPY)
        bool is_bullish = co == "Positive (+)" ? roc > 0 : roc < 0
        bool is_neutral = roc == 0
        
        // 2. Evaluate Judgement Strength (Based on threshold)
        bool is_strong = math.abs(roc) >= th
        
        string j_sig = ""
        color j_col = color.rgb(170, 175, 185) // Default Neutral Gray
        
        if is_neutral
            j_sig := "■"
            j_col := color.rgb(170, 175, 185)
        else if is_bullish
            j_sig := is_strong ? "▲▲" : "▲"
            j_col := color.rgb(0, 230, 118) // Bright Green for USD/JPY Bullish Pressure
        else
            j_sig := is_strong ? "▼▼" : "▼"
            j_col := color.rgb(255, 23, 68)  // Bright Red for USD/JPY Bearish Pressure
            
        // 3. Format Display Text: "Asset ROC%  [Judgement Sign]"
        string sign = roc > 0 ? "+" : ""
        string display_str = sign + str.tostring(roc, "#.##") + "%  " + j_sig
        
        array.push(j_txts, display_str)
        array.push(j_cols, j_col)

// ==========================================
// 2. 15-Asset Matrix Configuration
// ==========================================
gp_s1_5 = "Symbols 01 - 05 (Default Active)"
t1_en = input.bool(true, "S01", inline="s1", group=gp_s1_5, display=display.none), t1_tk = input.symbol("TVC:DXY", "", inline="s1", group=gp_s1_5, display=display.none), t1_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s1", group=gp_s1_5, display=display.none)
t2_en = input.bool(true, "S02", inline="s2", group=gp_s1_5, display=display.none), t2_tk = input.symbol("TVC:US10Y", "", inline="s2", group=gp_s1_5, display=display.none), t2_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s2", group=gp_s1_5, display=display.none)
t3_en = input.bool(true, "S03", inline="s3", group=gp_s1_5, display=display.none), t3_tk = input.symbol("FX:EURUSD", "", inline="s3", group=gp_s1_5, display=display.none), t3_co = input.string("Negative (-)", "", options=["Positive (+)", "Negative (-)"], inline="s3", group=gp_s1_5, display=display.none)
t4_en = input.bool(true, "S04", inline="s4", group=gp_s1_5, display=display.none), t4_tk = input.symbol("FX:GBPUSD", "", inline="s4", group=gp_s1_5, display=display.none), t4_co = input.string("Negative (-)", "", options=["Positive (+)", "Negative (-)"], inline="s4", group=gp_s1_5, display=display.none)
t5_en = input.bool(true, "S05", inline="s5", group=gp_s1_5, display=display.none), t5_tk = input.symbol("FX:AUDUSD", "", inline="s5", group=gp_s1_5, display=display.none), t5_co = input.string("Negative (-)", "", options=["Positive (+)", "Negative (-)"], inline="s5", group=gp_s1_5, display=display.none)

gp_s6_10 = "Symbols 06 - 10 (S06-07 Default Active)"
t6_en = input.bool(true, "S06", inline="s6", group=gp_s6_10, display=display.none), t6_tk = input.symbol("FX:USDCAD", "", inline="s6", group=gp_s6_10, display=display.none), t6_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s6", group=gp_s6_10, display=display.none)
t7_en = input.bool(true, "S07", inline="s7", group=gp_s6_10, display=display.none), t7_tk = input.symbol("TVC:NI225", "", inline="s7", group=gp_s6_10, display=display.none), t7_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s7", group=gp_s6_10, display=display.none)
t8_en = input.bool(false,"S08", inline="s8", group=gp_s6_10, display=display.none), t8_tk = input.symbol("FX:USDCHF", "", inline="s8", group=gp_s6_10, display=display.none), t8_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s8", group=gp_s6_10, display=display.none)
t9_en = input.bool(false,"S09", inline="s9", group=gp_s6_10, display=display.none), t9_tk = input.symbol("FX:EURJPY", "", inline="s9", group=gp_s6_10, display=display.none), t9_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s9", group=gp_s6_10, display=display.none)
t10_en = input.bool(false,"S10", inline="s10", group=gp_s6_10, display=display.none), t10_tk = input.symbol("FX:GBPJPY", "", inline="s10", group=gp_s6_10, display=display.none), t10_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s10", group=gp_s6_10, display=display.none)

gp_s11_15 = "Symbols 11 - 15 (Optional Custom)"
t11_en = input.bool(false,"S11", inline="s11", group=gp_s11_15, display=display.none), t11_tk = input.symbol("OANDA:XAUUSD", "", inline="s11", group=gp_s11_15, display=display.none), t11_co = input.string("Negative (-)", "", options=["Positive (+)", "Negative (-)"], inline="s11", group=gp_s11_15, display=display.none)
t12_en = input.bool(false,"S12", inline="s12", group=gp_s11_15, display=display.none), t12_tk = input.symbol("TVC:US30", "", inline="s12", group=gp_s11_15, display=display.none), t12_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s12", group=gp_s11_15, display=display.none)
t13_en = input.bool(false,"S13", inline="s13", group=gp_s11_15, display=display.none), t13_tk = input.symbol("TVC:SPX", "", inline="s13", group=gp_s11_15, display=display.none), t13_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s13", group=gp_s11_15, display=display.none)
t14_en = input.bool(false,"S14", inline="s14", group=gp_s11_15, display=display.none), t14_tk = input.symbol("BINANCE:BTCUSDT", "", inline="s14", group=gp_s11_15, display=display.none), t14_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s14", group=gp_s11_15, display=display.none)
t15_en = input.bool(false,"S15", inline="s15", group=gp_s11_15, display=display.none), t15_tk = input.symbol("FX:AUDJPY", "", inline="s15", group=gp_s11_15, display=display.none), t15_co = input.string("Positive (+)", "", options=["Positive (+)", "Negative (-)"], inline="s15", group=gp_s11_15, display=display.none)

// ==========================================
// 3. Data Acquisition & Security Handling
// ==========================================
f_roc(tk, en) =>
    target = en and tk != "" ? tk : syminfo.tickerid
    request.security(target, tf_input, ta.roc(close, roc_len))

roc1 = f_roc(t1_tk, t1_en),   roc2 = f_roc(t2_tk, t2_en),   roc3 = f_roc(t3_tk, t3_en)
roc4 = f_roc(t4_tk, t4_en),   roc5 = f_roc(t5_tk, t5_en),   roc6 = f_roc(t6_tk, t6_en)
roc7 = f_roc(t7_tk, t7_en),   roc8 = f_roc(t8_tk, t8_en),   roc9 = f_roc(t9_tk, t9_en)
roc10 = f_roc(t10_tk, t10_en), roc11 = f_roc(t11_tk, t11_en), roc12 = f_roc(t12_tk, t12_en)
roc13 = f_roc(t13_tk, t13_en), roc14 = f_roc(t14_tk, t14_en), roc15 = f_roc(t15_tk, t15_en)

// ==========================================
// 4. Directional Alignment Logic
// ==========================================
evaluate_symbol(en, roc, co) =>
    int a = en ? 1 : 0
    int bu = 0, int be = 0
    if en
        if co == "Positive (+)" ? roc > 0 : roc < 0
            bu := 1  // USD/JPY Bullish Factor
        else
            be := 1  // USD/JPY Bearish Factor
    [a, bu, be]

[a1, bu1, be1] = evaluate_symbol(t1_en, roc1, t1_co)
[a2, bu2, be2] = evaluate_symbol(t2_en, roc2, t2_co)
[a3, bu3, be3] = evaluate_symbol(t3_en, roc3, t3_co)
[a4, bu4, be4] = evaluate_symbol(t4_en, roc4, t4_co)
[a5, bu5, be5] = evaluate_symbol(t5_en, roc5, t5_co)
[a6, bu6, be6] = evaluate_symbol(t6_en, roc6, t6_co)
[a7, bu7, be7] = evaluate_symbol(t7_en, roc7, t7_co)
[a8, bu8, be8] = evaluate_symbol(t8_en, roc8, t8_co)
[a9, bu9, be9] = evaluate_symbol(t9_en, roc9, t9_co)
[a10, bu10, be10] = evaluate_symbol(t10_en, roc10, t10_co)
[a11, bu11, be11] = evaluate_symbol(t11_en, roc11, t11_co)
[a12, bu12, be12] = evaluate_symbol(t12_en, roc12, t12_co)
[a13, bu13, be13] = evaluate_symbol(t13_en, roc13, t13_co)
[a14, bu14, be14] = evaluate_symbol(t14_en, roc14, t14_co)
[a15, bu15, be15] = evaluate_symbol(t15_en, roc15, t15_co)

active_count = a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11+a12+a13+a14+a15
bull_count   = bu1+bu2+bu3+bu4+bu5+bu6+bu7+bu8+bu9+bu10+bu11+bu12+bu13+bu14+bu15
bear_count   = be1+be2+be3+be4+be5+be6+be7+be8+be9+be10+be11+be12+be13+be14+be15

max_aligned  = math.max(bull_count, bear_count)
ratio        = active_count > 0 ? max_aligned / active_count : 0

// ==========================================
// 5. Flash Gimmick Configuration (High Congruence Warning)
// ==========================================
is_flicker = math.floor(timenow / 250) % 2 == 0
color_flash_red  = is_flicker ? color.rgb(244, 67, 54) : color.rgb(44, 15, 20)
color_flash_text = is_flicker ? color.white : color.rgb(150, 150, 150)

// Status Color Evaluation
var color status_bg = color.rgb(30, 34, 42)
var color status_fg = color.white
var string status_text = "NEUTRAL"

if active_count > 0
    if ratio >= 0.75
        status_bg := color_flash_red
        status_fg := color_flash_text
        status_text := bull_count >= bear_count ? "🔥 STRONG USD/JPY BULL" : "🔥 STRONG USD/JPY BEAR"
    else if ratio >= 0.666
        status_bg := color.rgb(0, 200, 100)
        status_fg := color.black
        status_text := bull_count >= bear_count ? "📈 USD/JPY BULL" : "📉 USD/JPY BEAR"
    else
        status_bg := color.rgb(41, 121, 255)
        status_fg := color.white
        status_text := bull_count >= bear_count ? "⚡ MILD USD BIAS" : "⚡ MILD JPY BIAS"

// ==========================================
// 6. Flat Design HUD Rendering (2-Column Grid)
// ==========================================
var string[] act_tk    = array.new_string()
var string[] act_j_txt = array.new_string()
var color[]  act_j_col = array.new_color()

if barstate.islast
    array.clear(act_tk), array.clear(act_j_txt), array.clear(act_j_col)
    
    // Process active tracking datasets with Judgement evaluation
    push_data(t1_en, t1_tk, roc1, t1_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t2_en, t2_tk, roc2, t2_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t3_en, t3_tk, roc3, t3_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t4_en, t4_tk, roc4, t4_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t5_en, t5_tk, roc5, t5_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t6_en, t6_tk, roc6, t6_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t7_en, t7_tk, roc7, t7_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t8_en, t8_tk, roc8, t8_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t9_en, t9_tk, roc9, t9_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t10_en, t10_tk, roc10, t10_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t11_en, t11_tk, roc11, t11_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t12_en, t12_tk, roc12, t12_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t13_en, t13_tk, roc13, t13_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t14_en, t14_tk, roc14, t14_co, strong_th, act_tk, act_j_txt, act_j_col)
    push_data(t15_en, t15_tk, roc15, t15_co, strong_th, act_tk, act_j_txt, act_j_col)

    int N = array.size(act_tk)
    
    // Borderless flat design table layout
    table hud = table.new(get_position(tbl_pos), 4, 10, bgcolor=color.rgb(18, 22, 26), border_width=0)
    
    // Top status bar (Merged columns)
    table.merge_cells(hud, 0, 0, 3, 0)
    string match_info = " (" + str.tostring(max_aligned) + "/" + str.tostring(active_count) + ")"
    table.cell(hud, 0, 0, status_text + match_info, bgcolor=status_bg, text_color=status_fg, text_size=size.small)
    
    // Render active symbols into a 2-column grid
    if N > 0
        for i = 0 to N - 1
            int row_idx = 1 + math.floor(i / 2)
            int col_offset = (i % 2) * 2
            
            string name      = array.get(act_tk, i)
            string disp_text = array.get(act_j_txt, i)
            color  c_text    = array.get(act_j_col, i)
            
            // Solid background blocks with zero borders or shadows (Flat aesthetic)
            table.cell(hud, col_offset, row_idx, name, text_color=color.rgb(170, 175, 185), text_size=size.small, bgcolor=color.rgb(26, 30, 38))
            table.cell(hud, col_offset + 1, row_idx, disp_text, text_color=c_text, text_size=size.small, bgcolor=color.rgb(26, 30, 38))
````
