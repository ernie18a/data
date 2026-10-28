# ADX/DI Profile & Volume Footprint

- url: https://www.tradingview.com/script/X9edevPd/
- type: indicator
- pine_id: PUB;bd8f99232c294c2c8d3481f494777350
- version: 3.0

## Description

[b]🔶Overview[/b]
This script merges two powerful analytical frameworks—"Algorithmic ADX/DI Price Profile" and "High-Precision Volume Footprint"—into a single chart overlay. By moving Directional Movement data from the time axis (X-axis) to the price axis (Y-axis) and scanning lower timeframe (LTF) tick arrays, it accurately visualizes where trend energy is concentrated and how buyers and sellers interact at discrete price levels. This allows you to objectively verify market structure before committing capital.
[b]🔶System Modules and Execution Flow[/b]
[list]
[*]Volume Footprint Engine: Utilizes request.security_lower_tf() to scan up to 50 historical bars on a lower timeframe (down to 1-second for Premium users) to reconstruct intra-bar order flow. [Execution]: Toggle between "Individual Bars" mode for per-candle footprints, and "Composite (N Bars)" mode to aggregate order flow over a specified range into a single comprehensive structure.
[*]ADX/DI Profile Matrix: Computes standard 14-period DMI components, scalable via a Multi-Timeframe (MTF) engine. Generates fixed bounding boxes over historical sessions to project +DI, -DI, and ADX intensity as horizontal histograms. [Execution]: Profiles are visually separated (Left, Right, Center aligned). A real-time heatmap shader shifts from "Cold" to "Hot" based on energy concentration, instantly identifying trend exhaustion or accumulation zones.
[*]Local VWAP & Fibonacci Controller: Using the dynamically calculated profile range as an anchor, it draws a local Volume Weighted Average Price (VWAP) and customizable Fibonacci extensions, providing highly logical stop-loss and take-profit targets.
[*]Analytical HUD (Default OFF): A fixed 50-column matrix table dynamically tracks Delta, Total Volume, Total Buy, and Total Sell orders, eliminating the need to manually decipher individual numbers inside the boxes.
[/list]
[b]🔶Configuration and Filtering Options[/b]
[list]
[*]Resolution & Boundaries: Defines profile row counts (10 to 50 tiers; max 40 recommended for perfect stability, though this does not apply to line rendering) and width multipliers. When trading highly volatile assets like crypto or indices, reducing this to 30 thickens the price buckets and improves visibility.
[*]Algorithmic Noise Filter: A critical threshold gate (0.0 to 1.0). Price tiers failing to meet this relative intensity ratio are visually muted. Increasing the default 0.08 to 0.15 (15%) mathematically erases low-impact price zones, leaving only institutional-level support/resistance clusters.
[*]Volume Weight Toggle: An option to fuse volume data into DMI calculations. Prioritizes directional moves backed by real capital over empty price spikes.
[*]Premium Seconds-Timeframe Guard: An automated downgrade protocol to ensure script stability. If a non-Premium plan is detected, it automatically converts 1-second (1S) requests to a 1-minute timeframe to prevent fatal array compilation errors.
[/list]
[b]🔶Trading Strategy and Practical Applications[/b]
[list]
[*]"Wait & See" Filter (Avoiding Chop): The system's color shader acts as your first gate of discipline. If the ADX profile (center) shows "Cold" colors (e.g., dark orange/amber), it means trend energy is low. Do not trade; remain in a no-position state until the ADX blocks turn "Hot" (bright yellow), confirming massive algorithmic participation.
[*]Absorption and Exhaustion Setups: Watch the Footprint engine boxes drawn over the candles closely. If a massive spike of aggressive buying (high positive delta, green text) occurs, yet the candle fails to break out and is immediately capped by a dense -DI profile block (right side, Hot Red), this is "Absorption." Buyers are trapped. Enter short right below this Point of Control (POC) with a tight stop-loss just above the profile box.
[*]VWAP / Fibonacci Targeting: Once an entry is validated by Footprint delta, use the dynamically plotted VWAP as a baseline. For longs, target the upper Fibonacci bands (0.618 or 1.000). The beauty of this system is that these bands are derived strictly from the profiled session's "volume", reacting mathematically to the current market environment rather than arbitrary historical swings.
[/list]
[b]🔶Architecture and Quantitative Logic (Code Breakdown)[/b]
This script relies on multiple mathematical matrices to transform time-based indicators into price-based structures.
1. Footprint Volume Distribution (Tick Estimation)




[pine]ticks_1s = math.round((c_h - c_l) / syminfo.mintick) + 1
v_tick = c_v / ticks_1s[/pine]

[list]
[*]Why this calculation is performed: TradingView cannot provide sub-second Bid/Ask data. To measure aggressive market participation at specific price levels and objectively distinguish local buying absorption from selling pressure, the engine mathematically divides the lower timeframe bar's spread (High - Low) and distributes volume evenly across each tick to synthesize aggressive trading behavior.
[*]Actual Output Value: A raw Float representing estimated volume at a single price tick. For example, if a 1-second volume (c_v) is 100 contracts and the spread covers 5 ticks, the output (v_tick) is exactly 20.0 per tick. Absolute volumes are formatted as strings (e.g., "1.5K") for the UI, while net delta is output to the HUD summary table as raw positive/negative floats.
[/list]
2. DMI Profile Allocation and Normalization




[pine]net_di_ratio = math.abs(raw_p_plus - raw_p_minus) / (raw_p_plus + raw_p_minus)
p_plus = raw_p_plus * c_vol * (1 + net_di_ratio)[/pine]

[list]
[*]Why this calculation is performed: To pinpoint the exact price nodes where trend strength (ADX) and direction (+DI/-DI) physically occurred, filtering out empty volatility. Standard DMI ignores volume; this script multiplies DI intensity by trading volume (c_vol) and scales it via net_di_ratio to highlight zones where one side completely overwhelmed the other.
[*]Actual Output Value: A large integer/float representing the local energy assigned to that price tier. If raw +DI is 30, raw -DI is 10, and volume is 1,000, the net_di_ratio is 20 / 40 = 0.5. The final p_plus output assigned to that tier is 30 * 1000 * 1.5 = 45,000 energy points.
[/list]
3. Box Scaling and Noise Filter




[pine]ratio_plus = val_plus / max_plus 
// If ratio_plus >= noise_filter, render the box[/pine]


[list]
[*]Why this calculation is performed: To eliminate market noise. max_plus is the Point of Control (POC)—the price tier with the absolute maximum energy. All other tiers are divided by this maximum to output a percentage (0.0 to 1.0). The noise filter (default 0.08, or 8%) culls tiers holding less than 8% of the POC's intensity.
[*]Actual Output Value: A Float ratio between 0.0 and 1.0. A tier with 22,500 energy against a POC of 45,000 outputs 0.5. This 0.5 is passed directly to the f_get_heatmap_color function, outputting an RGBA hex color code that dynamically blends "Cold" and "Hot" variables based on intensity.
[/list]
4. VWAP and Geometric Fibonacci Derivation
[list]
[*]Why this calculation is performed: To establish a baseline fair value and logical standard deviation bands derived directly from the profiled session's volume distribution.
[*]Actual Output Value: Exact absolute price coordinates (Y-axis floats). The Local VWAP is calculated by dividing the sum of (Typical Price * Volume) by Total Volume within the profile window. Fibonacci levels are output as the absolute distance from the VWAP to the session high/low multiplied by standard ratios (0.382, 0.618, 1.000). These are mapped as solid, dashed, or dotted lines across the X-axis bounds of the profile box.
[/list]
[b]🔶Capabilities and Limitations[/b]
[list]
[*]Capabilities: Synthesizes massive LTF data arrays into clean, readable UI boxes without repainting. Modular layout prevents candlesticks from being obscured.
[*]Limitations: TradingView imposes strict limits of 500 boxes, 500 lines, and 500 labels per script. On highly volatile assets with deep tick resolution, maximizing row_count or setting footprint lookbacks to 50 bars may cause older UI elements to clip (disappear) due to platform-level garbage collection constraints.
[/list]

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (C) ALT_analyst

//@version=6
indicator("ADX/DI Profile & Volume Footprint", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ~~ [ Constants & Tooltips ] {
const string GRP_SESS   = " [ SYSTEM ] Profile Session Settings"
const string GRP_MTF    = " [ SYSTEM ] MTF & Volume"
const string GRP_LAY    = " [ H.U.D ] Layout & Opacity"
const string GRP_LBL    = " [ LABELS ] Values & Display"
const string GRP_FP_VAL = " [ DISPLAY ] FOOTPRINT VALUE LABEL"
const string GRP_ST     = " [ STYLE ] Lines & POC"
const string GRP_VWAP   = " [ SYSTEM ] Local VWAP & Fibonacci"
const string GRP_DMI    = " [ ENGINE ] ALGORITHMIC DMI"
const string GRP_COL    = " [ SHADER ] INHERITED COLORS"
const string GRP_CORE   = " [ SYSTEM ] CORE HIGH-PRECISION SCAN"
const string GRP_DISP   = " [ DISPLAY ] CANDLES & FOOTPRINT"
const string GRP_BG     = " [ BACKGROUND ] SYMBOL -> BACKGROUND"
const string GRP_FPLBL  = " [ LABEL ] SYMBOL -> LABEL"
const string GRP_FPTXT  = " [ TEXT ] FOOTPRINT DATA"

const string OPT_L      = "Left Aligned"
const string OPT_R      = "Right Aligned"
const string OPT_C      = "Center Aligned"

const string STY_HIST   = "Histogram"
const string STY_LINE   = "Line"
const string STY_BOX    = "Box"

const string L_SOLID    = "Solid"
const string L_DASHED   = "Dashed"
const string L_DOTTED   = "Dotted"

const string FP_IND     = "Individual Bars"
const string FP_COMP    = "Composite (N Bars)"
const string ROW_AUTO   = "Auto (20 Tiers)"
const string ROW_MAN    = "Manual"

// Tooltips
const string TT_PP      = "Defines the number of bars per profile session block. Interacts with Historical Sessions to segment the chart."
const string TT_PN      = "Limits historical sessions to max 3 to prevent exceeding TradingView's 500-box drawing limit while maintaining optimal performance."
const string TT_RC      = "Defines the vertical resolution (number of price tiers) for the ADX/DI profile. Higher values provide finer detail. Max 40 recommended."
const string TT_UMTF    = "Enables Higher Timeframe (HTF) projection for the DMI calculation, allowing you to view macro trends on a micro chart."
const string TT_UVOL    = "Multiplies the ADX/DI engine's output by the volume of each bar, mathematically integrating price momentum with trading activity."
const string TT_PSTY    = "Choose how to display profiles: 'Histogram' creates solid blocks, while 'Line' draws a minimal outer boundary. Interacts directly with Opacity settings."
const string TT_WPCT    = "Adjusts the maximum horizontal width of the +DI and -DI profiles relative to the session duration to prevent overlapping."
const string TT_MWPCT   = "Adjusts the maximum horizontal width specifically for the ADX profile to maintain visual hierarchy against directional indicators."
const string TT_OPN     = "Base opacity for standard profile nodes. Works alongside the inherited 3-step gradient colors."
const string TT_OPA     = "Highlight opacity for nodes where ADX or DI signals a strong trend. Directly triggered by the 'ADX Threshold' setting in the Engine group."
const string TT_GTS     = "Auto-scales or fixes the size of all numeric values displayed on the ADX/DI profiles."
const string TT_TSR     = "Filters out visual noise by only displaying value labels for nodes that exceed this specific ratio (e.g., 0.8 = 80%) of the maximum session node."
const string TT_SFPV    = "If ON, displays footprint values as isolated labels outside the profile boxes, ideal for preventing visual clutter in dense areas."
const string TT_TSRF    = "Shows footprint volume text only for rows exceeding this ratio of the maximum volume, keeping the chart clean."
const string TT_POC     = "Highlights the Point of Control (POC) - the absolute specific price level with the highest accumulation in the current session."
const string TT_VWAP    = "Draws a localized Volume Weighted Average Price (VWAP) strictly bound to the session block, utilizing fibonacci bands for dynamic Support/Resistance."
const string TT_DMIL    = "Core lookback length for the algorithmic ADX/DI calculation."
const string TT_ADXT    = "The threshold that defines the 'High Density' alert state. Values exceeding this trigger the 'High Density Opacity' shift."
const string TT_NOIS    = "Filters out low-momentum price rows from being drawn entirely. 0.08 means nodes under 8% of max momentum are hidden."
const string TT_COL     = "3-step gradient colors based on relative intensity. C1 is low noise, C2 is active trend, C3 is peak momentum."
const string TT_FPM     = "Switches the footprint engine between Individual Bars (max 10) and Composite multi-bar volume clusters."
const string TT_PREM    = "Premium Plan or Higher. If OFF and a seconds timeframe is specified, it will be forcefully downgraded to a 1-minute minimum timeframe to prevent request errors."
const string TT_RSM     = "Row Size Mode. Auto calculates tiers dynamically via ATR; Manual uses the absolute Ticks per Row setting."
//~~~~~}

// ~~ [ Inputs & UI Definitions ] {
int prof_period = input.int(50, "Period (Bars)", minval=1, maxval=50, group=GRP_SESS, tooltip=TT_PP)
int prof_num    = input.int(1, "Historical Sessions", minval=1, maxval=3, group=GRP_SESS, tooltip=TT_PN)
int row_count   = input.int(50, "Resolution (Row Count)", minval=10, maxval=50, group=GRP_SESS, tooltip=TT_RC)

bool use_mtf    = input.bool(false, "Project Higher Timeframe (MTF)", group=GRP_MTF, tooltip=TT_UMTF)
string htf_res  = input.timeframe("60", "Higher Timeframe", group=GRP_MTF)
bool use_vol    = input.bool(true, "Weight Energy by Volume", group=GRP_MTF, tooltip=TT_UVOL)

string prof_style = input.string(STY_HIST, "Profile Style", options=[STY_HIST, STY_LINE], group=GRP_LAY, tooltip=TT_PSTY)
string lay_plus   = input.string(OPT_L, "+DI Layout", options=[OPT_L, OPT_R, OPT_C], group=GRP_LAY)
string lay_minus  = input.string(OPT_R, "-DI Layout", options=[OPT_L, OPT_R, OPT_C], group=GRP_LAY)
string lay_adx    = input.string(OPT_L, "ADX Layout", options=[OPT_L, OPT_R, OPT_C], group=GRP_LAY)

float widthPct       = input.float(0.45, "Max Width Pct", minval=0.1, maxval=1.0, step=0.05, group=GRP_LAY, tooltip=TT_WPCT)
float midVolWidthPct = input.float(0.15, "ADX Width Pct", minval=0.05, maxval=0.5, step=0.05, group=GRP_LAY, tooltip=TT_MWPCT)
int opacityNorm      = input.int(60, "Normal Opacity (%)", minval=0, maxval=100, step=5, group=GRP_LAY, tooltip=TT_OPN)
int opacityAlrt      = input.int(40, "High Density Opacity (%)", minval=0, maxval=100, step=5, group=GRP_LAY, tooltip=TT_OPA)
bool show_bg         = input.bool(true, "Show Background Area", group=GRP_LAY)
color bg_color       = input.color(color.new(#131722, 60), "Background Color", group=GRP_LAY)

bool show_val_lbl     = input.bool(true, "Show Profile Values", group=GRP_LBL)
color lbl_bg_col      = input.color(color.new(color.black, 60), "Label BG Color", group=GRP_LBL)
string global_txt_size= input.string(size.auto, "Global Text Size (Auto-Scale)", options=[size.auto, size.tiny, size.small, size.normal, size.large, size.huge], group=GRP_LBL, tooltip=TT_GTS)
float txt_shw_rat     = input.float(0.8, "Label Show Threshold", minval=0.1, maxval=1.0, step=0.1, group=GRP_LBL, tooltip=TT_TSR)

bool show_fp_val_lbl  = input.bool(false, "Show Footprint Value Label", group=GRP_FP_VAL, tooltip=TT_SFPV)
string lay_fp_val     = input.string(OPT_C, "Footprint Value Label Layout", options=[OPT_L, OPT_R, OPT_C], group=GRP_FP_VAL)
float txt_shw_rat_fp  = input.float(0.5, "Footprint Label Show Threshold", minval=0.1, maxval=1.0, step=0.1, group=GRP_FP_VAL, tooltip=TT_TSRF)

bool show_poc_a = input.bool(true, "ADX POC", inline="pa", group=GRP_ST, tooltip=TT_POC)
color col_poc_a = input.color(#FFFF00, "", inline="pa", group=GRP_ST)
int wid_poc_a   = input.int(2, "", minval=1, maxval=5, inline="pa", group=GRP_ST)
string sty_poc_a= input.string(L_DASHED, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="pa", group=GRP_ST)

bool show_poc_p = input.bool(true, "+DI POC", inline="pp", group=GRP_ST)
color col_poc_p = input.color(#00FFFF, "", inline="pp", group=GRP_ST)
int wid_poc_p   = input.int(1, "", minval=1, maxval=5, inline="pp", group=GRP_ST)
string sty_poc_p= input.string(L_DOTTED, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="pp", group=GRP_ST)

bool show_poc_m = input.bool(true, "-DI POC", inline="pm", group=GRP_ST)
color col_poc_m = input.color(#FF0000, "", inline="pm", group=GRP_ST)
int wid_poc_m   = input.int(1, "", minval=1, maxval=5, inline="pm", group=GRP_ST)
string sty_poc_m= input.string(L_DOTTED, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="pm", group=GRP_ST)

bool show_vwap = input.bool(true, "VWAP", inline="v", group=GRP_VWAP, tooltip=TT_VWAP)
color col_vwap = input.color(color.new(color.white, 30), "", inline="v", group=GRP_VWAP)
int wid_vwap   = input.int(2, "", minval=1, maxval=5, inline="v", group=GRP_VWAP)
string sty_vwap= input.string(L_SOLID, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="v", group=GRP_VWAP)

bool show_fib = input.bool(true, "Show Fibonacci", group=GRP_VWAP)
bool f1_on = input.bool(true, "Fib 1:", inline="f1", group=GRP_VWAP)
float f1_vl = input.float(0.382, "", step=0.05, inline="f1", group=GRP_VWAP)
color f1_cl = input.color(color.new(color.red, 30), "", inline="f1", group=GRP_VWAP)
int f1_wd = input.int(1, "W", minval=1, maxval=5, inline="f1", group=GRP_VWAP)
string f1_st = input.string(L_DOTTED, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="f1", group=GRP_VWAP)

bool f2_on = input.bool(true, "Fib 2:", inline="f2", group=GRP_VWAP)
float f2_vl = input.float(0.618, "", step=0.05, inline="f2", group=GRP_VWAP)
color f2_cl = input.color(color.new(color.green, 30), "", inline="f2", group=GRP_VWAP)
int f2_wd = input.int(3, "W", minval=1, maxval=5, inline="f2", group=GRP_VWAP)
string f2_st = input.string(L_DASHED, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="f2", group=GRP_VWAP)

bool f3_on = input.bool(true, "Fib 3:", inline="f3", group=GRP_VWAP)
float f3_vl = input.float(1.000, "", step=0.05, inline="f3", group=GRP_VWAP)
color f3_cl = input.color(color.new(color.purple, 30), "", inline="f3", group=GRP_VWAP)
int f3_wd = input.int(2, "W", minval=1, maxval=5, inline="f3", group=GRP_VWAP)
string f3_st = input.string(L_SOLID, "", options=[L_SOLID, L_DASHED, L_DOTTED], inline="f3", group=GRP_VWAP)

int dmi_len      = input.int(14, "ADX/DI Length", minval=1, group=GRP_DMI, tooltip=TT_DMIL)
int adx_thresh   = input.int(25, "ADX Threshold", group=GRP_DMI, tooltip=TT_ADXT)
float noise_filter = input.float(0.08, "Noise Filter (0.0~1.0)", minval=0.0, step=0.02, group=GRP_DMI, tooltip=TT_NOIS) 

color up_C1 = input.color(#01579B, "Up Cold (Noise)", group=GRP_COL, inline="up", tooltip=TT_COL)
color up_C2 = input.color(#2962FF, "Up Warm (Trend)", group=GRP_COL, inline="up")
color up_C3 = input.color(#00E5FF, "Up Hot (Chance)", group=GRP_COL, inline="up")
color dn_C1 = input.color(#311B92, "Dn Cold (Noise)", group=GRP_COL, inline="dn")
color dn_C2 = input.color(#C51162, "Dn Warm (Trend)", group=GRP_COL, inline="dn")
color dn_C3 = input.color(#FF5252, "Dn Hot (Chance)", group=GRP_COL, inline="dn")
color ax_C1 = input.color(#FF8F00, "ADX Cold", group=GRP_COL, inline="ax")
color ax_C2 = input.color(#FFD54F, "ADX Warm", group=GRP_COL, inline="ax")
color ax_C3 = input.color(#FFFF00, "ADX Hot", group=GRP_COL, inline="ax")

string fp_mode    = input.string(FP_COMP, "Footprint Engine Mode", options=[FP_IND, FP_COMP], group=GRP_CORE, tooltip=TT_FPM)
bool is_premium   = input.bool(false, "Premium Plan or Higher (Allow Seconds TF)", group=GRP_CORE, tooltip=TT_PREM)
int lookback_bars = input.int(50, "Reference Range (N Bars)", minval=1, maxval=50, group=GRP_CORE)
string ltf_res_input = input.timeframe("1S", "Lower Timeframe (LTF)", group=GRP_CORE)

bool is_sec_tf    = str.contains(ltf_res_input, "S")
string actual_ltf = (not is_premium and is_sec_tf) ? "1" : ltf_res_input

bool show_hud       = input.bool(false, "Show Summary HUD", group=GRP_DISP)
string fp_style     = input.string(STY_BOX, "Footprint Style", options=[STY_BOX, STY_LINE], group=GRP_DISP)
string lay_fp       = input.string(OPT_L, "Footprint Layout", options=[OPT_L, OPT_R, OPT_C], group=GRP_DISP)
float width_mult    = input.float(0.5, "Profile Width Multiplier", minval=0.1, step=0.5, group=GRP_DISP)
string row_size_mode= input.string(ROW_AUTO, "Row Size Mode", options=[ROW_MAN, ROW_AUTO], group=GRP_DISP, tooltip=TT_RSM)
int ticks_per_row   = input.int(1, "Ticks per Row (Manual Mode Only)", minval=1, group=GRP_DISP)
bool show_border    = input.bool(true, "Show Borders on All Boxes", group=GRP_DISP)
color col_border    = input.color(color.new(color.gray, 60), "Border Color", group=GRP_DISP)

color bg_col_high   = input.color(color.new(#00332a, 0), "Volume High (Max)", group=GRP_BG)
color bg_col_mid    = input.color(color.new(#00ff00, 20), "Volume Mid (50%)", group=GRP_BG)
color bg_col_low    = input.color(color.new(#c8e6c9, 60), "Volume Low (Min)", group=GRP_BG)

color col_poc_bg    = input.color(color.white, "POC Box Color", group=GRP_FPLBL)
color col_poc_txt   = input.color(color.black, "POC Text Color", group=GRP_FPLBL)

color txt_col_fp    = input.color(color.white, "Text Color (Neutral)", group=GRP_FPTXT)
color txt_col_pos   = input.color(color.new(#089981, 0), "Text Color (Plus Delta)", group=GRP_FPTXT)
color txt_col_neg   = input.color(color.new(#F23645, 0), "Text Color (Minus Delta)", group=GRP_FPTXT)
//~~~~~}

// ~~ [ Data Calculation & Core Functions ] {
[d_p, d_m, a_v] = ta.dmi(dmi_len, dmi_len)
[s_dp, s_dm, s_av, s_vol] = request.security(syminfo.tickerid, use_mtf ? htf_res : timeframe.period, [d_p, d_m, a_v, volume])

[ltf_o, ltf_h, ltf_l, ltf_c, ltf_v] = request.security_lower_tf(syminfo.tickerid, actual_ltf, [open, high, low, close, volume])
float global_atr = ta.atr(14)

f_format_k(float val) =>
    float abs_val = math.abs(val)
    string res = ""
    if abs_val >= 1000000
        res := str.tostring(val / 1000000, "#.##") + "M"
    else if abs_val >= 1000
        res := str.tostring(val / 1000, "#.##") + "K"
    else
        res := str.tostring(val, "#.#")
    res

f_get_tf_mult(string tf) =>
    int ltf_sec = timeframe.in_seconds(timeframe.period)
    int htf_sec = timeframe.in_seconds(tf)
    float mult = (htf_sec > 0 and ltf_sec > 0) ? (htf_sec / ltf_sec) : 1.0
    math.max(1, math.round(mult))

int tf_mult = use_mtf ? f_get_tf_mult(htf_res) : 1
int actual_period = math.min(prof_period * tf_mult, 4000)

f_sty(string s) => s == L_DASHED ? line.style_dashed : s == L_DOTTED ? line.style_dotted : line.style_solid

f_get_heatmap_color(float r, color c1, color c2, color c3) =>
    color c = c1
    if r <= 0.25
        c := color.from_gradient(r, 0.0, 0.25, c1, color.from_gradient(0.5, 0.0, 1.0, c1, c2))
    else if r <= 0.50
        c := color.from_gradient(r, 0.25, 0.50, color.from_gradient(0.5, 0.0, 1.0, c1, c2), c2)
    else if r <= 0.75
        c := color.from_gradient(r, 0.50, 0.75, c2, color.from_gradient(0.5, 0.0, 1.0, c2, c3))
    else
        c := color.from_gradient(r, 0.75, 1.0, color.from_gradient(0.5, 0.0, 1.0, c2, c3), c3)
    c

f_get_coords(string layout_type, int p_start_bar, int p_end_bar, int mid_bar, int w) =>
    int bl = 0
    int br = 0
    if layout_type == OPT_L
        bl := p_start_bar
        br := p_start_bar + w
    else if layout_type == OPT_R
        br := p_end_bar
        bl := p_end_bar - w
    else if layout_type == OPT_C
        bl := mid_bar - math.round(w / 2)
        br := mid_bar + math.round(w / 2)
    [bl, br]

f_draw_fib(line[] l_arr, float val, color base_c, int width, string sty, bool on, float l_vwap, float d_up, float d_dn, int p_start, int p_end, int p_idx) =>
    if on
        float price_u = l_vwap + (d_up * val)
        float price_d = l_vwap - (d_dn * val)
        float current_t = color.t(base_c)
        float new_t = math.min(100, current_t + (p_idx * 15))
        color prof_col = color.new(base_c, new_t)
        string ln_sty = f_sty(sty)
        array.push(l_arr, line.new(p_start, price_u, p_end, price_u, xloc=xloc.bar_index, color=prof_col, style=ln_sty, width=width))
        array.push(l_arr, line.new(p_start, price_d, p_end, price_d, xloc=xloc.bar_index, color=prof_col, style=ln_sty, width=width))
//~~~~~}

// ~~ [ Drawing Engine (Combined Profile & Footprint) ] {
var box[]  all_boxes  = array.new_box()
var line[] all_lines  = array.new_line()
var label[] all_labels = array.new_label()

var box[] fp_boxes = array.new_box()
var label[] fp_labels = array.new_label()
var line[] fp_lines = array.new_line()

var table summary_table = table.new(position.bottom_right, 55, 5, bgcolor=color.white, border_width=1, border_color=color.gray)

if barstate.islast
    // Efficient Array Cleanup
    for bx in all_boxes
        box.delete(bx)
    array.clear(all_boxes)
    
    for ln in all_lines
        line.delete(ln)
    array.clear(all_lines)
    
    for lbl in all_labels
        label.delete(lbl)
    array.clear(all_labels)

    for bx in fp_boxes
        box.delete(bx)
    array.clear(fp_boxes)
    
    for lbl in fp_labels
        label.delete(lbl)
    array.clear(fp_labels)
    
    for ln in fp_lines
        line.delete(ln)
    array.clear(fp_lines)
    
    table.clear(summary_table, 0, 0, 54, 4)
    color global_border_c = show_border ? col_border : na

    // ------------------------------------------
    // PART A: LOWER TIMEFRAME FOOTPRINT ENGINE
    // ------------------------------------------
    if fp_mode == FP_IND
        for b_offset = lookback_bars - 1 to 0
            if b_offset >= bar_index or array.size(ltf_v) == 0 or array.size(ltf_v) <= b_offset
                continue
                
            float[] ltf_o_arr = ltf_o[b_offset]
            float[] ltf_h_arr = ltf_h[b_offset]
            float[] ltf_l_arr = ltf_l[b_offset]
            float[] ltf_c_arr = ltf_c[b_offset]
            float[] ltf_v_arr = ltf_v[b_offset]
            
            int ltf_size = na(ltf_v_arr) ? 0 : array.size(ltf_v_arr)
            
            float bar_l = low[b_offset]
            float bar_h = high[b_offset]
            
            float current_atr = global_atr[b_offset]
            if na(current_atr) or current_atr == 0
                current_atr := close[b_offset] * 0.005 
                
            int auto_ticks = math.max(1, math.round((current_atr / 20) / syminfo.mintick))
            int active_ticks = row_size_mode == ROW_AUTO ? auto_ticks : ticks_per_row
            float step  = syminfo.mintick * active_ticks
            
            int total_r = math.ceil((bar_h - bar_l) / step) + 1
            
            float[] ask_v_arr = array.new_float(total_r, 0.0)
            float[] bid_v_arr = array.new_float(total_r, 0.0)
            
            float total_v_bar = 0.0
            float bought_t    = 0.0
            float sold_t      = 0.0
            float max_r_v     = 0.0
            
            if ltf_size > 0
                for i = 0 to ltf_size - 1
                    float c_o = array.get(ltf_o_arr, i)
                    float c_h = array.get(ltf_h_arr, i)
                    float c_l = array.get(ltf_l_arr, i)
                    float c_c = array.get(ltf_c_arr, i)
                    float c_v = array.get(ltf_v_arr, i)
                        
                    int ticks_1s = math.round((c_h - c_l) / syminfo.mintick) + 1
                    float v_tick = c_v / ticks_1s
                    
                    int s_idx = math.round((c_l - bar_l) / step)
                    int e_idx = math.round((c_h - bar_l) / step)
                    
                    for t_idx = s_idx to e_idx
                        if t_idx >= 0 and t_idx < total_r
                            if c_c > c_o
                                array.set(ask_v_arr, t_idx, array.get(ask_v_arr, t_idx) + v_tick)
                            else if c_c < c_o
                                array.set(bid_v_arr, t_idx, array.get(bid_v_arr, t_idx) + v_tick)
                            else
                                array.set(ask_v_arr, t_idx, array.get(ask_v_arr, t_idx) + (v_tick / 2))
                                array.set(bid_v_arr, t_idx, array.get(bid_v_arr, t_idx) + (v_tick / 2))

            for i = 0 to total_r - 1
                float ask_vol = array.get(ask_v_arr, i)
                float bid_vol = array.get(bid_v_arr, i)
                float total   = ask_vol + bid_vol
                max_r_v     := math.max(max_r_v, total)
                bought_t    += ask_vol
                sold_t      += bid_vol
                total_v_bar += total

            float delta = bought_t - sold_t
            
            int poc_idx = -1
            if max_r_v > 0
                for i = 0 to total_r - 1
                    if array.get(ask_v_arr, i) + array.get(bid_v_arr, i) == max_r_v
                        poc_idx := i
                        break
            
            int t_ctr = time[b_offset]
            int b_t_w = nz(time[b_offset] - time[b_offset + 1], time - time[1])
            int cell_w_t = math.round(b_t_w * 0.8 * width_mult) 

            float prev_fp_x = na
            float prev_fp_y = na
            
            // Pre-calculate label styles based on layout const
            string style_fp_lbl = lay_fp_val == OPT_L ? label.style_label_right : (lay_fp_val == OPT_R ? label.style_label_left : label.style_label_left)

            for i = 0 to total_r - 1
                float ask_vol = array.get(ask_v_arr, i)
                float bid_vol = array.get(bid_v_arr, i)
                float total   = ask_vol + bid_vol
                
                if total == 0
                    continue
                    
                float price_p = bar_l + (i * step)
                bool  is_poc  = (i == poc_idx)
                
                float fp_ratio = max_r_v > 0 ? total / max_r_v : 0.0
                bool show_fp_text = fp_ratio >= txt_shw_rat_fp
                
                string fp_txt = f_format_k(total)
                string fp_txt_box = (show_fp_val_lbl or not show_fp_text) ? "" : fp_txt

                int total_w = math.round(cell_w_t * (max_r_v > 0 ? total / max_r_v : 0))
                int b_left  = t_ctr
                int b_right = t_ctr + total_w

                if lay_fp == OPT_R
                    b_left  := t_ctr + cell_w_t - total_w
                    b_right := t_ctr + cell_w_t
                else if lay_fp == OPT_C
                    b_left  := t_ctr + math.round(cell_w_t / 2) - math.round(total_w / 2)
                    b_right := b_left + total_w

                int fp_tip_x = lay_fp == OPT_L ? b_right : (lay_fp == OPT_R ? b_left : b_right)

                float row_delta = ask_vol - bid_vol
                color dynamic_txt_col = is_poc ? col_poc_txt : (row_delta > 0 ? txt_col_pos : (row_delta < 0 ? txt_col_neg : txt_col_fp))
                
                float half_max = max_r_v * 0.5
                color grad_col = total >= half_max ? color.from_gradient(total, half_max, max_r_v, bg_col_mid, bg_col_high) : color.from_gradient(total, 0, half_max, bg_col_low, bg_col_mid)
                color box_bg  = is_poc ? col_poc_bg : grad_col
                
                if show_fp_val_lbl and show_fp_text
                    int label_x = lay_fp_val == OPT_L ? b_left : (lay_fp_val == OPT_R ? b_right : b_right)
                    array.push(fp_labels, label.new(label_x, price_p, fp_txt, xloc=xloc.bar_time, color=lbl_bg_col, textcolor=dynamic_txt_col, size=global_txt_size, style=style_fp_lbl))

                if fp_style == STY_LINE
                    if not na(prev_fp_x)
                        array.push(fp_lines, line.new(math.round(prev_fp_x), prev_fp_y, fp_tip_x, price_p, xloc=xloc.bar_time, color=box_bg, width=2))
                    prev_fp_x := fp_tip_x
                    prev_fp_y := price_p
                else
                    array.push(fp_boxes, box.new(
                        left = b_left, top = price_p + (step/2), right = b_right, bottom = price_p - (step/2),
                        xloc = xloc.bar_time, border_color = global_border_c, bgcolor = box_bg,
                        text = fp_txt_box, text_color = dynamic_txt_col, text_size = global_txt_size, 
                        text_halign = text.align_left, text_valign = text.align_center
                    ))
                
                if is_poc
                    array.push(fp_lines, line.new(x1=t_ctr, y1=price_p, x2=t_ctr + cell_w_t, y2=price_p, xloc=xloc.bar_time, color=color.black, style=line.style_dotted, width=1))

            if show_hud and total_v_bar > 0
                if b_offset == lookback_bars - 1
                    table.cell(summary_table, 0, 0, "Target Bar", text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=size.normal)
                    table.cell(summary_table, 0, 1, "Delta", text_color=color.black, text_size=size.normal, text_halign=text.align_left)
                    table.cell(summary_table, 0, 2, "Total Vol", text_color=color.black, text_size=size.normal, text_halign=text.align_left)
                    table.cell(summary_table, 0, 3, "Total Buy", text_color=color.black, text_size=size.normal, text_halign=text.align_left)
                    table.cell(summary_table, 0, 4, "Total Sell", text_color=color.black, text_size=size.normal, text_halign=text.align_left)

                int col_idx = lookback_bars - b_offset
                color delta_color = delta > 0 ? color.new(#089981, 0) : color.new(#F23645, 0)
                
                table.cell(summary_table, col_idx, 0, b_offset == 0 ? "Current" : str.tostring(b_offset) + " Bars Ago", text_color=color.black, bgcolor=color.new(color.gray, 95), text_size=size.normal)
                table.cell(summary_table, col_idx, 1, (delta > 0 ? "+" : "") + str.tostring(f_format_k(delta)), text_color=delta_color, text_size=size.normal, text_halign=text.align_right)
                table.cell(summary_table, col_idx, 2, str.tostring(f_format_k(total_v_bar)), text_color=color.black, text_size=size.normal, text_halign=text.align_right)
                table.cell(summary_table, col_idx, 3, str.tostring(f_format_k(bought_t)), text_color=color.new(#089981, 0), text_size=size.normal, text_halign=text.align_right)
                table.cell(summary_table, col_idx, 4, str.tostring(f_format_k(sold_t)), text_color=color.new(#F23645, 0), text_size=size.normal, text_halign=text.align_right)

    else if fp_mode == FP_COMP
        float comp_h = high[0]
        float comp_l = low[0]
        for b_offset = 0 to lookback_bars - 1
            if b_offset <= bar_index
                comp_h := math.max(comp_h, high[b_offset])
                comp_l := math.min(comp_l, low[b_offset])
                
        float current_atr = global_atr[0]
        if na(current_atr) or current_atr == 0
            current_atr := close[0] * 0.005 
            
        int auto_ticks = math.max(1, math.round((current_atr / 20) / syminfo.mintick))
        int active_ticks = row_size_mode == ROW_AUTO ? auto_ticks : ticks_per_row
        float step  = syminfo.mintick * active_ticks
        
        int total_r = math.ceil((comp_h - comp_l) / step) + 1
        
        float[] ask_v_arr = array.new_float(total_r, 0.0)
        float[] bid_v_arr = array.new_float(total_r, 0.0)
        
        float total_v_bar = 0.0
        float bought_t    = 0.0
        float sold_t      = 0.0
        float max_r_v     = 0.0
        
        for b_offset = lookback_bars - 1 to 0
            if b_offset >= bar_index or array.size(ltf_v) == 0 or array.size(ltf_v) <= b_offset
                continue
                
            float[] ltf_o_arr = ltf_o[b_offset]
            float[] ltf_h_arr = ltf_h[b_offset]
            float[] ltf_l_arr = ltf_l[b_offset]
            float[] ltf_c_arr = ltf_c[b_offset]
            float[] ltf_v_arr = ltf_v[b_offset]
            
            int ltf_size = na(ltf_v_arr) ? 0 : array.size(ltf_v_arr)
            if ltf_size > 0
                for i = 0 to ltf_size - 1
                    float c_o = array.get(ltf_o_arr, i)
                    float c_h = array.get(ltf_h_arr, i)
                    float c_l = array.get(ltf_l_arr, i)
                    float c_c = array.get(ltf_c_arr, i)
                    float c_v = array.get(ltf_v_arr, i)
                        
                    int ticks_1s = math.round((c_h - c_l) / syminfo.mintick) + 1
                    float v_tick = c_v / ticks_1s
                    
                    int s_idx = math.round((c_l - comp_l) / step)
                    int e_idx = math.round((c_h - comp_l) / step)
                    
                    for t_idx = s_idx to e_idx
                        if t_idx >= 0 and t_idx < total_r
                            if c_c > c_o
                                array.set(ask_v_arr, t_idx, array.get(ask_v_arr, t_idx) + v_tick)
                            else if c_c < c_o
                                array.set(bid_v_arr, t_idx, array.get(bid_v_arr, t_idx) + v_tick)
                            else
                                array.set(ask_v_arr, t_idx, array.get(ask_v_arr, t_idx) + (v_tick / 2))
                                array.set(bid_v_arr, t_idx, array.get(bid_v_arr, t_idx) + (v_tick / 2))

        for i = 0 to total_r - 1
            float ask_vol = array.get(ask_v_arr, i)
            float bid_vol = array.get(bid_v_arr, i)
            float total   = ask_vol + bid_vol
            max_r_v     := math.max(max_r_v, total)
            bought_t    += ask_vol
            sold_t      += bid_vol
            total_v_bar += total

        float delta = bought_t - sold_t
        
        int poc_idx = -1
        if max_r_v > 0
            for i = 0 to total_r - 1
                if array.get(ask_v_arr, i) + array.get(bid_v_arr, i) == max_r_v
                    poc_idx := i
                    break
        
        int b_t_w = nz(time[0] - time[1], 1000)
        int start_time = time[math.min(bar_index, lookback_bars - 1)]
        int cell_w_t = math.round((time[0] - start_time + b_t_w) * width_mult) 
        
        float prev_fp_x = na
        float prev_fp_y = na
        
        string style_fp_lbl = lay_fp_val == OPT_L ? label.style_label_right : (lay_fp_val == OPT_R ? label.style_label_left : label.style_label_left)

        for i = 0 to total_r - 1
            float ask_vol = array.get(ask_v_arr, i)
            float bid_vol = array.get(bid_v_arr, i)
            float total   = ask_vol + bid_vol
            
            if total == 0
                continue
                
            float price_p = comp_l + (i * step)
            bool  is_poc  = (i == poc_idx)
            
            float fp_ratio = max_r_v > 0 ? total / max_r_v : 0.0
            bool show_fp_text = fp_ratio >= txt_shw_rat_fp
            
            string fp_txt = f_format_k(total)
            string fp_txt_box = (show_fp_val_lbl or not show_fp_text) ? "" : fp_txt 

            int total_w = math.round(cell_w_t * (max_r_v > 0 ? total / max_r_v : 0))
            int b_left  = start_time
            int b_right = start_time + total_w

            if lay_fp == OPT_R
                b_left  := start_time + cell_w_t - total_w
                b_right := start_time + cell_w_t
            else if lay_fp == OPT_C
                b_left  := start_time + math.round(cell_w_t / 2) - math.round(total_w / 2)
                b_right := b_left + total_w

            int fp_tip_x = lay_fp == OPT_L ? b_right : (lay_fp == OPT_R ? b_left : b_right)

            float row_delta = ask_vol - bid_vol
            color dynamic_txt_col = is_poc ? col_poc_txt : (row_delta > 0 ? txt_col_pos : (row_delta < 0 ? txt_col_neg : txt_col_fp))
            
            float half_max = max_r_v * 0.5
            color grad_col = total >= half_max ? color.from_gradient(total, half_max, max_r_v, bg_col_mid, bg_col_high) : color.from_gradient(total, 0, half_max, bg_col_low, bg_col_mid)
            color box_bg  = is_poc ? col_poc_bg : grad_col
            
            if show_fp_val_lbl and show_fp_text
                int label_x = lay_fp_val == OPT_L ? b_left : (lay_fp_val == OPT_R ? b_right : b_right)
                array.push(fp_labels, label.new(label_x, price_p, fp_txt, xloc=xloc.bar_time, color=lbl_bg_col, textcolor=dynamic_txt_col, size=global_txt_size, style=style_fp_lbl))

            if fp_style == STY_LINE
                if not na(prev_fp_x)
                    array.push(fp_lines, line.new(math.round(prev_fp_x), prev_fp_y, fp_tip_x, price_p, xloc=xloc.bar_time, color=box_bg, width=2))
                prev_fp_x := fp_tip_x
                prev_fp_y := price_p
            else
                array.push(fp_boxes, box.new(
                    left = b_left, top = price_p + (step/2), right = b_right, bottom = price_p - (step/2),
                    xloc = xloc.bar_time, border_color = global_border_c, bgcolor = box_bg,
                    text = fp_txt_box, text_color = dynamic_txt_col, text_size = global_txt_size, 
                    text_halign = text.align_left, text_valign = text.align_center
                ))
            
            if is_poc
                array.push(fp_lines, line.new(x1=start_time, y1=price_p, x2=start_time + cell_w_t, y2=price_p, xloc=xloc.bar_time, color=color.black, style=line.style_dotted, width=1))

        if show_hud and total_v_bar > 0
            table.cell(summary_table, 0, 0, "Range", text_color=color.black, bgcolor=color.new(color.gray, 90), text_size=size.normal)
            table.cell(summary_table, 0, 1, "Delta", text_color=color.black, text_size=size.normal, text_halign=text.align_left)
            table.cell(summary_table, 0, 2, "Total Vol", text_color=color.black, text_size=size.normal, text_halign=text.align_left)
            table.cell(summary_table, 0, 3, "Total Buy", text_color=color.black, text_size=size.normal, text_halign=text.align_left)
            table.cell(summary_table, 0, 4, "Total Sell", text_color=color.black, text_size=size.normal, text_halign=text.align_left)

            color delta_color = delta > 0 ? color.new(#089981, 0) : color.new(#F23645, 0)
            table.cell(summary_table, 1, 0, str.tostring(lookback_bars) + " Bars", text_color=color.black, bgcolor=color.new(color.gray, 95), text_size=size.normal)
            table.cell(summary_table, 1, 1, (delta > 0 ? "+" : "") + str.tostring(f_format_k(delta)), text_color=delta_color, text_size=size.normal, text_halign=text.align_right)
            table.cell(summary_table, 1, 2, str.tostring(f_format_k(total_v_bar)), text_color=color.black, text_size=size.normal, text_halign=text.align_right)
            table.cell(summary_table, 1, 3, str.tostring(f_format_k(bought_t)), text_color=color.new(#089981, 0), text_size=size.normal, text_halign=text.align_right)
            table.cell(summary_table, 1, 4, str.tostring(f_format_k(sold_t)), text_color=color.new(#F23645, 0), text_size=size.normal, text_halign=text.align_right)


    // ------------------------------------------
    // PART B: ADX/DI VOLUME PROFILE ENGINE
    // ------------------------------------------
    // Pre-calculate style and layout variables to avoid loop recalculation
    int max_w_bars = math.round(actual_period * widthPct)
    int adx_w_bars = math.round(actual_period * midVolWidthPct)
    string align_p = lay_plus == OPT_L ? label.style_label_left : (lay_plus == OPT_R ? label.style_label_right : label.style_label_left)
    string align_m = lay_minus == OPT_L ? label.style_label_left : (lay_minus == OPT_R ? label.style_label_right : label.style_label_left)
    string align_a = lay_adx == OPT_L ? label.style_label_left : (lay_adx == OPT_R ? label.style_label_right : label.style_label_left)
    string ln_sty_pa = f_sty(sty_poc_a)
    string ln_sty_pp = f_sty(sty_poc_p)
    string ln_sty_pm = f_sty(sty_poc_m)

    for p = 0 to prof_num - 1
        int p_end_bar   = bar_index - (p * actual_period)
        int p_start_bar = p_end_bar - actual_period + 1
        
        int calc_end_bar = p_end_bar
        int draw_mid_bar = math.round((p_start_bar + calc_end_bar) / 2)

        if p_start_bar < 0
            continue
            
        int offset_end   = math.max(0, bar_index - calc_end_bar)
        int offset_start = math.max(0, bar_index - p_start_bar)
        
        float s_high = high[offset_end]
        float s_low  = low[offset_end]
        
        for offset = offset_end to offset_start
            s_high := math.max(s_high, high[offset])
            s_low  := math.min(s_low, low[offset])
                
        if na(s_high) or na(s_low) or s_high == s_low
            s_high := close[offset_end] + (syminfo.mintick * 5)
            s_low  := close[offset_end] - (syminfo.mintick * 5)

        if show_bg
            array.push(all_boxes, box.new(left=p_start_bar, top=s_high, right=calc_end_bar, bottom=s_low, xloc=xloc.bar_index, border_color=na, bgcolor=bg_color))
            
        float step_price = (s_high - s_low) / row_count
        
        float[] row_plus_acc  = array.new_float(row_count, 0.0)
        float[] row_minus_acc = array.new_float(row_count, 0.0)
        float[] row_adx_acc   = array.new_float(row_count, 0.0)
        float[] row_touches   = array.new_float(row_count, 0.0)

        float sum_vol = 0.0
        float sum_src_vol = 0.0

        for offset = offset_end to offset_start
            float v_raw = use_mtf ? nz(s_vol[offset], 1) : nz(volume[offset], 1)
            float c_vol = (use_vol and v_raw > 0) ? v_raw : 1.0
            
            float typical_p = (high[offset] + low[offset] + close[offset]) / 3
            sum_vol += c_vol
            sum_src_vol += typical_p * c_vol

            float raw_p_plus  = nz(s_dp[offset])
            float raw_p_minus = nz(s_dm[offset])
            float net_di_ratio = (raw_p_plus + raw_p_minus) == 0 ? 0 : math.abs(raw_p_plus - raw_p_minus) / (raw_p_plus + raw_p_minus)

            float p_plus  = raw_p_plus * c_vol * (1 + net_di_ratio)
            float p_minus = raw_p_minus * c_vol * (1 + net_di_ratio)
            float c_adx   = nz(s_av[offset]) * c_vol * (1 + net_di_ratio)
            
            int start_row = math.floor((low[offset] - s_low) / step_price)
            int end_row   = math.floor((high[offset] - s_low) / step_price)
            start_row := math.max(0, math.min(start_row, row_count - 1))
            end_row   := math.max(0, math.min(end_row, row_count - 1))
            
            int rows_touched = (end_row - start_row) + 1
            
            for r = start_row to end_row
                array.set(row_plus_acc, r, array.get(row_plus_acc, r) + (p_plus / rows_touched))
                array.set(row_minus_acc, r, array.get(row_minus_acc, r) + (p_minus / rows_touched))
                array.set(row_adx_acc, r, array.get(row_adx_acc, r) + (c_adx / rows_touched))
                array.set(row_touches, r, array.get(row_touches, r) + 1)

        float local_vwap = sum_vol > 0 ? sum_src_vol / sum_vol : na

        float max_plus  = array.max(row_plus_acc)
        float max_minus = array.max(row_minus_acc)
        float max_adx   = array.max(row_adx_acc)
        
        int poc_adx_idx   = array.indexof(row_adx_acc, max_adx)
        int poc_plus_idx  = array.indexof(row_plus_acc, max_plus)
        int poc_minus_idx = array.indexof(row_minus_acc, max_minus)
                
        max_plus  := max_plus <= 0 ? 1.0 : max_plus
        max_minus := max_minus <= 0 ? 1.0 : max_minus
        max_adx   := max_adx <= 0 ? 1.0 : max_adx

        float prev_x_p = na, float prev_y_p = na
        float prev_x_m = na, float prev_y_m = na
        float prev_x_a = na, float prev_y_a = na

        for r = 0 to row_count - 1
            float val_plus  = array.get(row_plus_acc, r)
            float val_minus = array.get(row_minus_acc, r)
            float val_adx   = array.get(row_adx_acc, r)
            float touches   = array.get(row_touches, r)
            
            float ratio_plus  = val_plus / max_plus
            float ratio_minus = val_minus / max_minus
            float ratio_adx   = val_adx / max_adx
            
            float avg_adx = touches > 0 ? val_adx / touches : 0
            bool is_adx_strong = avg_adx >= adx_thresh
            bool bull_chance = is_adx_strong and (val_plus > val_minus * 1.2)
            bool bear_chance = is_adx_strong and (val_minus > val_plus * 1.2)
            
            float b_bot = s_low + (r * step_price)
            float b_top = s_low + ((r + 1) * step_price)
            float box_mid = (b_top + b_bot) / 2

            // --- Plus DI ---
            int w_p = math.max(0, math.round(max_w_bars * ratio_plus))
            [bl_p, br_p] = f_get_coords(lay_plus, p_start_bar, calc_end_bar, draw_mid_bar, w_p)
            int x_tip_p = lay_plus == OPT_L ? br_p : (lay_plus == OPT_R ? bl_p : br_p)
            color c_plus_base  = f_get_heatmap_color(ratio_plus, up_C1, up_C2, up_C3)
            int op_p = bull_chance ? opacityAlrt : opacityNorm

            if prof_style == STY_LINE
                if not na(prev_x_p)
                    array.push(all_lines, line.new(math.round(prev_x_p), prev_y_p, x_tip_p, box_mid, xloc=xloc.bar_index, color=c_plus_base, width=2))
                prev_x_p := x_tip_p
                prev_y_p := box_mid
            else
                if ratio_plus >= noise_filter
                    array.push(all_boxes, box.new(bl_p, b_top, br_p, b_bot, xloc=xloc.bar_index, border_color=na, bgcolor=color.new(c_plus_base, op_p)))
                
            if show_val_lbl and ratio_plus >= txt_shw_rat
                int x_p = lay_plus == OPT_L ? br_p : (lay_plus == OPT_R ? bl_p : br_p)
                array.push(all_labels, label.new(x_p, box_mid, f_format_k(val_plus), xloc=xloc.bar_index, color=lbl_bg_col, textcolor=c_plus_base, size=global_txt_size, style=align_p))

            // --- Minus DI ---
            int w_m = math.max(0, math.round(max_w_bars * ratio_minus))
            [bl_m, br_m] = f_get_coords(lay_minus, p_start_bar, calc_end_bar, draw_mid_bar, w_m)
            int x_tip_m = lay_minus == OPT_L ? br_m : (lay_minus == OPT_R ? bl_m : br_m)
            color c_minus_base = f_get_heatmap_color(ratio_minus, dn_C1, dn_C2, dn_C3)
            int op_m = bear_chance ? opacityAlrt : opacityNorm

            if prof_style == STY_LINE
                if not na(prev_x_m)
                    array.push(all_lines, line.new(math.round(prev_x_m), prev_y_m, x_tip_m, box_mid, xloc=xloc.bar_index, color=c_minus_base, width=2))
                prev_x_m := x_tip_m
                prev_y_m := box_mid
            else
                if ratio_minus >= noise_filter
                    array.push(all_boxes, box.new(bl_m, b_top, br_m, b_bot, xloc=xloc.bar_index, border_color=na, bgcolor=color.new(c_minus_base, op_m)))
                
            if show_val_lbl and ratio_minus >= txt_shw_rat
                int x_m = lay_minus == OPT_L ? br_m : (lay_minus == OPT_R ? bl_m : br_m)
                array.push(all_labels, label.new(x_m, box_mid, f_format_k(val_minus), xloc=xloc.bar_index, color=lbl_bg_col, textcolor=c_minus_base, size=global_txt_size, style=align_m))

            // --- ADX ---
            int w_a = math.max(0, math.round(adx_w_bars * ratio_adx))
            [bl_a, br_a] = f_get_coords(lay_adx, p_start_bar, calc_end_bar, draw_mid_bar, w_a)
            int x_tip_a = lay_adx == OPT_L ? br_a : (lay_adx == OPT_R ? bl_a : br_a)
            color c_adx_base = f_get_heatmap_color(ratio_adx, ax_C1, ax_C2, ax_C3)
            int op_a = is_adx_strong ? opacityAlrt : opacityNorm

            if prof_style == STY_LINE
                if not na(prev_x_a)
                    array.push(all_lines, line.new(math.round(prev_x_a), prev_y_a, x_tip_a, box_mid, xloc=xloc.bar_index, color=c_adx_base, width=2))
                prev_x_a := x_tip_a
                prev_y_a := box_mid
            else
                if ratio_adx >= noise_filter
                    array.push(all_boxes, box.new(bl_a, b_top, br_a, b_bot, xloc=xloc.bar_index, border_color=na, bgcolor=color.new(c_adx_base, op_a)))
                
            if show_val_lbl and ratio_adx >= txt_shw_rat
                int x_a = lay_adx == OPT_L ? br_a : (lay_adx == OPT_R ? bl_a : br_a)
                array.push(all_labels, label.new(x_a, box_mid, f_format_k(val_adx), xloc=xloc.bar_index, color=lbl_bg_col, textcolor=c_adx_base, size=global_txt_size, style=align_a))

            if show_poc_a and r == poc_adx_idx
                array.push(all_lines, line.new(p_start_bar, box_mid, calc_end_bar, box_mid, xloc=xloc.bar_index, color=col_poc_a, style=ln_sty_pa, width=wid_poc_a))
            if show_poc_p and r == poc_plus_idx
                array.push(all_lines, line.new(p_start_bar, box_mid, calc_end_bar, box_mid, xloc=xloc.bar_index, color=col_poc_p, style=ln_sty_pp, width=wid_poc_p))
            if show_poc_m and r == poc_minus_idx
                array.push(all_lines, line.new(p_start_bar, box_mid, calc_end_bar, box_mid, xloc=xloc.bar_index, color=col_poc_m, style=ln_sty_pm, width=wid_poc_m))

        if show_vwap and not na(local_vwap)
            array.push(all_lines, line.new(p_start_bar, local_vwap, calc_end_bar, local_vwap, xloc=xloc.bar_index, color=col_vwap, style=f_sty(sty_vwap), width=wid_vwap))
            if show_fib
                float dist_up = s_high - local_vwap
                float dist_dn = local_vwap - s_low
                f_draw_fib(all_lines, f1_vl, f1_cl, f1_wd, f1_st, f1_on, local_vwap, dist_up, dist_dn, p_start_bar, calc_end_bar, p)
                f_draw_fib(all_lines, f2_vl, f2_cl, f2_wd, f2_st, f2_on, local_vwap, dist_up, dist_dn, p_start_bar, calc_end_bar, p)
                f_draw_fib(all_lines, f3_vl, f3_cl, f3_wd, f3_st, f3_on, local_vwap, dist_up, dist_dn, p_start_bar, calc_end_bar, p)
//~~~~~}
````
