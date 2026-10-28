# Dual Log Regression Channels [BigBeluga]

- url: https://www.tradingview.com/script/Xp4URelH-Dual-Log-Regression-Channels-BigBeluga/
- type: indicator
- pine_id: PUB;6a69dd2b544740f8942ab5e6f2a43170
- version: 1.0

## Description

[b]Dual Log Regression Channels [BigBeluga][/b] is a highly advanced multi-timeframe mathematical modeling terminal engineered for TradingView. It maps, projects, and blends two independent logarithmic regression channels directly onto your asset layout screen to deliver an institutional-grade perspective on trend structure, market cycles, and structural volume distributions.

[image]https://www.tradingview.com/x/TXnc0fxX/[/image]

By separating price discovery parameters into a long-term Macro Channel and an execution-focused Short Term Channel, this tool effectively resolves the classic trader conflict of assessing structural trend directions while looking for immediate micro execution setups. Rather than treating market space as flat, standard geometric lines, this engine runs an advanced curve-fitting algorithm over your data to follow the exponential nature of capital expansion and distribution.

[b]🔵 INTUITIVE SYSTEM ARCHITECTURE & ENGINE FEATURES[/b]

[b]1. Logarithmic Regression Curve Optimization[/b]
[list]
[*] [b]Non-Linear Structural Tracking:[/b] Standard linear regression struggles with volatile crypto or high-growth equity trends over massive lookback structures. This script continuously converts incoming data matrices into mathematical log-space, computes a best-fit ordinary least squares (OLS) linear progression, and converts the output back into exponential value curves.
[*] [b]Dual Horizons Convergence Layer:[/b] Tracks an extensive trend anchor block (defaulting to 300 bars) simultaneously with a highly responsive, high-velocity swing lookback matrix (defaulting to 50 bars). This exposes localized micro contractions occurring right at major macro boundary extremes.
[*] [b]Visual Deviation Spacing Bands:[/b] Channels automatically map out distinct volatility boundaries based on real-time Standard Deviation multipliers. This defines predictable mathematical risk corridors where asset expansions typically exhaust and snap back toward the median baseline.
[/list]

[b]2. Predictive Channel Extension & Real-Time Trend Direction Arrows[/b]
[list]
[*] [b]Dynamic Origin Trend Arrows:[/b] The engine processes a dedicated directional diagnostic framework at the precise historical start (origin node) of each lookback channel. It generates sharp, high-visibility glyph trend arrows ([b]⇗[/b] for structural uptrends and [b]⇘[/b] for structural downtrends). These arrows offer an instant, real-time assessment of the mathematically calculated baseline slope, entirely bypassing visual guesswork when channels run relatively flat.
[*] [b]Forward-Projected Space Models:[/b] When enabled, both the Macro and Short-Term structural bands project forward into the future chart space blank zone (e.g., 50 bars ahead for Macro, 20 bars for Short-Term). This lets you visually identify intercept locations and major trend crossroads long before price action arrives.
[/list]

[b]3. Adaptive Embedded Channel Volume Profiles (VP)[/b]
[image]https://www.tradingview.com/x/PTlnc8Pb/[/image]
[list]
[*] [b]Integrated Block Volume Binning Matrix:[/b] Moving beyond basic fixed or visible range volume profiles, this module segments and collects transacted volume profiles exclusively inside the exact coordinate boundaries of each respective channel.
[*] [b]Dynamic Coordinate-Aligned Shading Bars:[/b] The volume profile rows scale and project outward utilizing advanced polyline geometry arrays, maintaining structural alignment with the slope of the moving channel boundaries.
[*] [b]Point of Control (POC) Trailing Baselines:[/b] Automatically tracks and renders a crisp, high-visibility solid horizontal baseline ([b]POC Line[/b]) marking the exact price bin location that attracted the highest volume concentration throughout that lookback phase.
[/list]

[b]4. Volumetric Delta Tracking Panels[/b]
[image]https://www.tradingview.com/x/uqGxqwct/[/image]
[list]
[*] [b]Buy vs. Sell Volume Accumulation Blocks:[/b] Aggregates total execution volume during the lookback period, classifying volume based on bar polarity.
[*] [b]Net Order Flow Delta Percentages:[/b] Computes and prints the precise net mathematical buying/selling pressure delta inside the channel. This reveals quiet accumulation behavior or hidden distribution trends directly alongside your spatial boundary drawings.
[/list]

[b]🔵 SYSTEMATIC EXECUTION STRATEGIES & RISK INTERPRETATION[/b]

[list]
[*] [b]Confluence Zone Intercept Trading:[/b] Look for setups where the Short Term Channel’s outer standard deviation boundaries align directly with the Macro Channel's major structural lines. When a high-velocity micro asset trend exhausts itself at a long-term macro floor or ceiling, it marks a highly efficient, asymmetric inflection zone for trend continuation entries or macro reversals.
[*] [b]Volume Profile POC Mean Reversion Matrix:[/b] The volume profile POC lines show where massive institutional blocks shifted hands inside that channel's lifespan. If the market stretches thin near an upper outer boundary but net volumetric volume indicators begin shifting toward seller control, look for a swift mean-reversion move down toward the high-liquidity POC baseline node.
[image]https://www.tradingview.com/x/rucfCQbE/[/image]
[*] [b]Trend Acceleration vs. Overextended Breakouts:[/b] When an asset forces a candle close completely outside the projected log channel boundaries, it flags an exceptional shift in trend velocity. If the Volume Delta percentage prints an explosive spike in that direction, it supports a trend acceleration play. If volume is thin, it warns you of a predatory, overextended fakeout structure that is likely to snap back into the central channel values.
[/list]

[b]🔵 INTERFACE CONFIGURATION AND PARAMETERS[/b]

[list]
[*] [b]Lookback & Deviation Tuning Blocks:[/b] Customize historical calculation boundaries and volatility widths separately for both trend layers to match any asset class or time frame preference.
[*] [b]Volume Profile Customization:[/b] Control the precise resolution of the volume profile by adjusting row count bins and max bar widths to match your specific layout.
[*] [b]Clean Workspace Overrides:[/b] Toggle visibility filters to hide median baselines, remove raw background asset lines, or completely customize color theme hex codes to fit cleanly within your setup without causing visual clutter.
[/list]

Transform your charting environment from basic straight lines into an exponential, volume-weighted structural map with the [b]Dual Log Regression Channels[/b] terminal.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Dual Log Regression Channels [BigBeluga]", overlay=true, max_bars_back = 1000)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// --- Macro Channel Inputs ---
bool  macro_show_channel= input.bool(true, "Show Macro Channel", group = "Macro (Long Term) Channel")

int   macro_length      = input.int(300, "Macro Lookback Period", group = "Macro (Long Term) Channel")
float macro_width       = input.float(2.0, "Macro Channel Width (StDev)", step = 0.1, group = "Macro (Long Term) Channel")
int   macro_line_w      = input.int(2, "Macro Outer Lines Width", minval=1, maxval=10, group = "Macro (Long Term) Channel")
bool  macro_mid_disp    = input.bool(true, "Show Macro Mid Line", group = "Macro (Long Term) Channel")
color macro_col_up      = input.color(#311b92, "Macro Upper Line", group = "Macro (Long Term) Channel")
color macro_col_mid     = input.color(color.blue, "Macro Mid Line", group = "Macro (Long Term) Channel")
color macro_col_low     = input.color(#311b92, "Macro Lower Line", group = "Macro (Long Term) Channel")
color macro_col_fill    = input.color(color.new(color.blue, 95), "Macro Background Fill", group = "Macro (Long Term) Channel")
bool  macro_show_stats  = input.bool(true, "Show Macro Volume Stats", group = "Macro (Long Term) Channel")
bool  macro_extend      = input.bool(true, "Extend Macro Channel", group = "Macro Future Extension")
int   macro_ext_bars    = input.int(50, "Macro Extension Bars", minval=1, group = "Macro Future Extension")

// --- Macro Profile Inputs ---
bool  macro_show_vp     = input.bool(true, "Show Macro Volume Profile", group = "Macro Volume Profile")
int   macro_bins        = input.int(50, "Macro Profile Bins (Rows)", minval=5, maxval=100, group = "Macro Volume Profile")
int   macro_max_w       = input.int(25, "Macro Max Profile Width (Bars)", minval=5, maxval=100, group = "Macro Volume Profile")
color macro_vp_color    = input.color(color.new(color.blue, 50), "Macro Profile Color", group = "Macro Volume Profile")
bool  macro_show_poc    = input.bool(true, "Show Macro POC Line", group = "Macro Volume Profile")
color macro_poc_color   = input.color(color.red, "Macro POC Color", group = "Macro Volume Profile")

// --- Short Term Channel Inputs ---
bool  short_show_channel= input.bool(true, "Show Short Channel", group = "Short Term Channel")

int   short_length      = input.int(50, "Short Term Lookback Period", group = "Short Term Channel")
float short_width       = input.float(1.5, "Short Term Channel Width (StDev)", step = 0.1, group = "Short Term Channel")
int   short_line_w      = input.int(1, "Short Term Outer Lines Width", minval=1, maxval=10, group = "Short Term Channel")
bool  short_mid_disp    = input.bool(true, "Show Short Term Mid Line", group = "Short Term Channel")
color short_col_up      = input.color(#e65100, "Short Term Upper Line", group = "Short Term Channel")
color short_col_mid     = input.color(color.orange, "Short Term Mid Line", group = "Short Term Channel")
color short_col_low     = input.color(#e65100, "Short Term Lower Line", group = "Short Term Channel")
color short_col_fill    = input.color(color.new(color.orange, 95), "Short Term Background Fill", group = "Short Term Channel")
bool  short_show_stats  = input.bool(true, "Show Short Term Volume Stats", group = "Short Term Channel")
bool  short_extend      = input.bool(true, "Extend Short Term Channel", group = "Short Term Future Extension")
int   short_ext_bars    = input.int(20, "Short Term Extension Bars", minval=1, group = "Short Term Future Extension")

// --- Short Profile Inputs ---
bool  short_show_vp     = input.bool(true, "Show Short Volume Profile", group = "Short Term Volume Profile")
int   short_bins        = input.int(50, "Short Profile Bins (Rows)", minval=5, maxval=100, group = "Short Term Volume Profile")
int   short_max_w       = input.int(15, "Short Max Profile Width (Bars)", minval=5, maxval=100, group = "Short Term Volume Profile")
color short_vp_color    = input.color(color.new(color.orange, 50), "Short Profile Color", group = "Short Term Volume Profile")
bool  short_show_poc    = input.bool(true, "Show Short POC Line", group = "Short Term Volume Profile")
color short_poc_color   = input.color(color.red, "Short POC Color", group = "Short Term Volume Profile")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// --- Logarithmic Regression Calculation Engine ---
f_log_regression(src, length) =>
    float sumX      = 0.0
    float sumY      = 0.0
    float sumXSqr   = 0.0
    float sumXY     = 0.0

    for i = 0 to length - 1
        val = math.log(src[i])
        per = i + 1.0
        sumX += per
        sumY += val
        sumXSqr += per * per
        sumXY += val * per

    slope = (length * sumXY - sumX * sumY) / (length * sumXSqr - sumX * sumX)
    intercept = (sumY - slope * sumX) / length

    [slope, intercept]

// --- Text Utility for Volume Metric Formatting ---
f_format_vol(float vol) =>
    string res = ""
    if vol >= 1000000
        res := str.tostring(vol / 1000000, "#.#") + "M"
    else if vol >= 1000
        res := str.tostring(vol / 1000, "#.#") + "k"
    else
        res := str.tostring(vol, "#")
    res

// --- Core Channel Processing Function ---
f_render_channel(length, channel_width, line_w, mid_disp, col_up, col_mid, col_low, fill_color, show_stats, show_vp, bin_count, max_w, vp_color, extend_ch, ext_bars, show_poc, poc_color) =>
    // Mathematical Core Regression Data Fetching
    [slope, intercept] = f_log_regression(close, length)
    
    float reg_start = math.exp(intercept + slope * length)
    float reg_end   = math.exp(intercept)
    float deviation = ta.stdev(close, length)

    // Log-space boundary definitions
    float upper_start = reg_start + deviation * channel_width
    float upper_end   = reg_end + deviation * channel_width
    float lower_start = reg_start - deviation * channel_width
    float lower_end   = reg_end - deviation * channel_width

    // Persistence instantiation for structural drawings
    var line mid_line       = na
    var line upper_line     = na
    var line lower_line     = na
    var linefill fill       = na
    var label dir_label     = na
    var label stats_lbl     = na
    var line mid_ext        = na
    var line upper_ext      = na
    var line lower_ext      = na
    var polyline vp_poly    = na
    var line poc_line       = na

    // Update Channel Median Coordinates
    if mid_disp
        if na(mid_line)
            mid_line := line.new(bar_index[length], reg_start, bar_index, reg_end, color=col_mid, style=line.style_dashed)
        else
            mid_line.set_xy1(bar_index[length], reg_start)
            mid_line.set_xy2(bar_index, reg_end)
    else
        line.delete(mid_line)

    // Update Channel Boundary Coordinates
    if na(upper_line)
        upper_line := line.new(bar_index[length], upper_start, bar_index, upper_end, width=line_w, color=col_up)
    else
        upper_line.set_xy1(bar_index[length], upper_start)
        upper_line.set_xy2(bar_index, upper_end)
        upper_line.set_width(line_w)

    if na(lower_line)
        lower_line := line.new(bar_index[length], lower_start, bar_index, lower_end, width=line_w, color=col_low)
    else
        lower_line.set_xy1(bar_index[length], lower_start)
        lower_line.set_xy2(bar_index, lower_end)
        lower_line.set_width(line_w)

    // Manage Background Shading Area
    if na(fill)
        fill := linefill.new(upper_line, lower_line, fill_color)
    else
        fill.set_color(fill_color)

    // Process Future-Extension Metric Lines
    if extend_ch
        float reg_fwd   = math.exp(intercept - slope * ext_bars)
        float upper_fwd = reg_fwd + deviation * channel_width
        float lower_fwd = reg_fwd - deviation * channel_width
        
        if mid_disp
            if na(mid_ext)
                mid_ext := line.new(bar_index, reg_end, bar_index + ext_bars, reg_fwd, color=col_mid, style=line.style_dotted)
            else
                mid_ext.set_xy1(bar_index, reg_end)
                mid_ext.set_xy2(bar_index + ext_bars, reg_fwd)
        else
            line.delete(mid_ext)

        if na(upper_ext)
            upper_ext := line.new(bar_index, upper_end, bar_index + ext_bars, upper_fwd, color=col_up, style=line.style_dashed, width=line_w)
        else
            upper_ext.set_xy1(bar_index, upper_end)
            upper_ext.set_xy2(bar_index + ext_bars, upper_fwd)
            upper_ext.set_width(line_w)

        if na(lower_ext)
            lower_ext := line.new(bar_index, lower_end, bar_index + ext_bars, lower_fwd, color=col_low, style=line.style_dashed, width=line_w)
        else
            lower_ext.set_xy1(bar_index, lower_end)
            lower_ext.set_xy2(bar_index + ext_bars, lower_fwd)
            lower_ext.set_width(line_w)
    else
        line.delete(mid_ext)
        line.delete(upper_ext)
        line.delete(lower_ext)

    // Directional Metadata Labels Styling Rules
    bool is_uptrend = reg_end > reg_start
    string arrow_text = is_uptrend ? "⇗" : "⇘"
    float label_y     = is_uptrend ? lower_start : upper_start
    string label_style = is_uptrend ? label.style_label_upper_right : label.style_label_lower_right
    string label_style1 = is_uptrend ? label.style_label_lower_right : label.style_label_upper_right
    color label_text_color = is_uptrend ? col_up : col_low

    // Render Trend Markers
    if na(dir_label)
        dir_label := label.new(bar_index[length], label_y, text=arrow_text, style=label_style, color=color.new(color.black, 100), textcolor=label_text_color, size=size.large)
    else
        dir_label.set_xy(bar_index[length], label_y)
        dir_label.set_text(arrow_text)
        dir_label.set_style(label_style)
        dir_label.set_textcolor(label_text_color)
    
    // Slidably Tracking Inside Volumetric Arrays Block
    float buy_vol = 0.0
    float sell_vol = 0.0
    float[] bin_vols = array.new_float(bin_count, 0.0)

    for i = 0 to length - 1
        if close[i] > open[i]
            buy_vol += volume[i]
        else if close[i] < open[i]
            sell_vol += volume[i]
        
        if show_vp
            float hist_reg_mid    = math.exp(intercept + slope * i)
            float hist_upper_line = hist_reg_mid + deviation * channel_width
            float hist_lower_line = hist_reg_mid - deviation * channel_width
            float hist_height     = hist_upper_line - hist_lower_line
            
            if close[i] >= hist_lower_line and close[i] <= hist_upper_line
                float bar_bin_step = hist_height / bin_count
                int bin_index = math.floor((close[i] - hist_lower_line) / bar_bin_step)
                bin_index := math.min(math.max(bin_index, 0), bin_count - 1)
                array.set(bin_vols, bin_index, array.get(bin_vols, bin_index) + volume[i])
            
    float total_vol = buy_vol + sell_vol
    float delta_pct = total_vol > 0 ? ((buy_vol - sell_vol) / total_vol) * 100 : 0.0
    
    // Text strings metadata output compiling
    string buy_str   = f_format_vol(buy_vol)
    string sell_str  = f_format_vol(sell_vol)
    string delta_str = (delta_pct >= 0 ? "+" : "") + str.tostring(delta_pct, "#.#") + "%"
    string stats_text = "Buy: " + buy_str + "\nSell: " + sell_str + "\nDelta: " + delta_str

    // Output statistical analytics info block labels
    if show_stats and barstate.islast
        if na(stats_lbl)
            stats_lbl := label.new(bar_index[length], label_y, text=stats_text, style=label_style1, color=color.new(color.black, 100), textcolor=color.white, size=size.small)
        else
            stats_lbl.set_xy(bar_index[length], label_y)
            stats_lbl.set_text(stats_text)
    else
        label.delete(stats_lbl)

    // Generating Polyline Geometry Matrix Nodes
    if show_vp and barstate.islast
        float max_bin_vol = array.max(bin_vols)
        int poc_bin_idx = bin_vols.indexof(max_bin_vol) 
        
        chart.point[] vp_points = array.new<chart.point>()
        int start_index = bar_index[length]
        float total_start_height = upper_start - lower_start
        float start_bin_step = total_start_height / bin_count
        float channel_slope_per_bar = (reg_end - reg_start) / length

        if max_bin_vol > 0
            for idx = 0 to bin_count - 1
                float current_vol = array.get(bin_vols, idx)
                int calculated_width_bars = math.round((current_vol / max_bin_vol) * max_w)
                
                float price_bottom_start = lower_start + (idx * start_bin_step)
                float price_top_start    = price_bottom_start + start_bin_step

                float price_bottom_projected = price_bottom_start + (channel_slope_per_bar * calculated_width_bars)
                float price_top_projected    = price_top_start + (channel_slope_per_bar * calculated_width_bars)

                array.push(vp_points, chart.point.from_index(start_index, price_bottom_start))
                array.push(vp_points, chart.point.from_index(start_index + calculated_width_bars, price_bottom_projected))
                array.push(vp_points, chart.point.from_index(start_index + calculated_width_bars, price_top_projected))
                array.push(vp_points, chart.point.from_index(start_index, price_top_start))

            // Build fresh polyline matrix drawing array paths
            polyline.delete(vp_poly)
            vp_poly := polyline.new(vp_points, line_color=vp_color, fill_color=color.new(vp_color, 85), closed=false, line_width=1, force_overlay=true)
            
            // Draw tracking POC markers
            if show_poc
                float poc_offset_from_bottom = (poc_bin_idx + 0.5) * start_bin_step
                float poc_start_y = lower_start + poc_offset_from_bottom
                float poc_end_y   = lower_end + poc_offset_from_bottom
                
                if na(poc_line)
                    poc_line := line.new(start_index, poc_start_y, bar_index, poc_end_y, color=poc_color, width=2, style=line.style_solid)
                else
                    line.set_xy1(poc_line, start_index, poc_start_y)
                    line.set_xy2(poc_line, bar_index, poc_end_y)
            else
                line.delete(poc_line)
    else
        polyline.delete(vp_poly)
        line.delete(poc_line)

    true

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// --- Trigger Independent Rendering Channels Executions ---
if macro_show_channel
    f_render_channel(macro_length, macro_width, macro_line_w, macro_mid_disp, macro_col_up, macro_col_mid, macro_col_low, macro_col_fill, macro_show_stats, macro_show_vp, macro_bins, macro_max_w, macro_vp_color, macro_extend, macro_ext_bars, macro_show_poc, macro_poc_color)
if short_show_channel
    f_render_channel(short_length, short_width, short_line_w, short_mid_disp, short_col_up, short_col_mid, short_col_low, short_col_fill, short_show_stats, short_show_vp, short_bins, short_max_w, short_vp_color, short_extend, short_ext_bars, short_show_poc, short_poc_color)

// }
````
