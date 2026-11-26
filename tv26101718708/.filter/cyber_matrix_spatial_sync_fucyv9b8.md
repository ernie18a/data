# Cyber Matrix [Spatial Sync]

- url: https://www.tradingview.com/script/FuCYv9B8/
- type: indicator
- pine_id: PUB;90aab6a5527e4be3b61c97e6d571e95a
- version: 3.0

## Description

[b]◆Overview[/b]
[list]
[*]The "Cyber Matrix [Spatial Sync]" is a next-generation analytical tool that integrates Spatial Volume Profiling, real-time Momentum (RSI) tracking, and Spatial Geometry into a single, highly optimized Head-Up Display (HUD). Expanding upon traditional price action analysis, it renders order flow as a live ASCII matrix to synchronize market liquidity with spatial coordinates.
[*]This allows traders to objectively verify hidden support/resistance zones and momentum accumulation before the market makes its move.
[/list]
◆[b]System Modules and Execution Flow[/b]
[list]
[*]Holographic VP & ASCII Matrix: Scans a defined historical window and reconstructs volume distribution as a dynamic ASCII terminal rather than standard boxes. Projects price levels, the Point of Control (POC), and momentum density directly onto the chart's spatial background. []Dynamic Geometric Anchoring: An algorithmic coordinate system that tracks market structure. Users can seamlessly toggle between "Auto Pivot" (snaps to structural swing highs/lows), "Rolling Lookback" (fluidly trails the current price), or "Step Profile" (archives historical matrices).
[*]Spatial Geometry (Hexagonal Matrix) Engine: Automatically projects Hexagonal boundaries anchored to dynamic pivot points. Inspired by W.D. Gann's Hexagon Chart and the mathematical efficiency of honeycomb structures (perfect packing), this visualizes where market liquidity is optimally constrained. []Confluence Signal Engine: Fuses the Madrid EMA (baseline trend) with RSI crosses. Emits strict, algorithmic buy/sell signals colored in Neon Cyan (Bullish) and Neon Magenta (Bearish).
[/list]
[b]◆Configuration and Filtering Options[/b]
[list]
[*]HUD Resolution & Boundaries: Defines the vertical row count and horizontal text width. Adjusting this allows traders to scale the ASCII projection seamlessly from high-timeframe macro views down to 1-minute scalping environments. Geometry Toggles: Independent visibility controls for Hexagonal polygons, Parallel Channels, and Mathematical Labels, ensuring the UI remains pristine.
[*]Cyber Theme Opacity: Fully customizable Alpha (transparency) controls for grid overlays and glowing polylines, optimized for dark-mode trading environments.
[/list]
[b]◆Trading Strategy and Practical Applications[/b]
[list]
[*]The Spatial Sync Setup: Do not trade in the void. Wait for the price to compress near the edge of a Hexagonal boundary. If the ASCII HUD at that exact price level shows thick Volume blocks (█) and the Status reads "OVERRIDE (CYAN)", execute a Long position. The geometry provides the exact spatial entry, while the HUD confirms the liquidity. 
[*]Momentum Divergence via ASCII Pulse: Monitor the "TEMPORAL MOMENTUM" array at the bottom of the HUD. If the price is making a new high, but the pulse blocks degrade from solid (█) to hollow (░), algorithmic momentum is bleeding out. Prepare for a reversal.
[/list]
[b]◆Architecture and Quantitative Logic (Code Breakdown)[/b]
This script relies on multi-dimensional array processing and polyline rendering to synthesize geometry and volume. 
[list=1]
[*]RSI-Weighted Volume Bins: Standard Volume Profiles only show "how much" was traded, ignoring trend aggression. This engine multiplies the local RSI momentum by the volume traded at that specific price bucket, effectively mapping momentum into a spatial dimension. The output dictates the visual density of the HUD strings.
[*]ASCII Block Normalization: Drawing hundreds of individual boxes per price level crashes TradingView's memory limits. By mathematically normalizing the volume against a maximum width integer and utilizing the str.repeat() function, the script bypasses graphical limits to render an infinitely scalable histogram using raw text strings.
[/list]
[b]◆Capabilities & Limitations[/b]

Capabilities (System Advantages): 
Bypassing Draw Limits for High-Res Profiling: By relying on string manipulation (str.repeat) and a minimal number of labels (label.new) instead of heavy box drawings (box.new), the system avoids TradingView's object limits. This deploys a lightweight, steplessly scalable histogram without freezing the browser.

Dimensional Integration of Momentum & Volume: Expresses the RSI strength formed at a specific price tier as visual text density (█, ▒, ░). This allows instant, intuitive analysis of whether buyers or sellers were more aggressive at a specific node. 

Dynamic Volatility Tracking & Archiving: The Auto Pivot mode (ta.pivothigh/low) automatically scales geometric shapes to match recent market swings, eliminating manual drawing. The Step Profile mode projects up to 5 historical sessions side-by-side to track liquidity migration.

Limitations (Platform Constraints): 
Finite Historical Archiving: Pine Script enforces strict hard limits per script (max 100 polylines, 500 labels). Increasing the archive count (profile_count) to the absolute limit or selecting excessively long periods will trigger hardcoded garbage collection, clipping the oldest HUD elements first.

Mitigations (Practical Countermeasures): 
Aggressor Estimation via Alternative Logic: To compensate for the lack of tick data, the script uses a proprietary "Volume × Local RSI Momentum" weighting algorithm. This statistically approximates relative buyer/seller aggression at specific price tiers, achieving accuracy highly viable for live trading without perfect order flow data.

Memory Management & Scope Optimization: Traders are advised to focus analysis on the most recent liquidity (1 to 3 sessions) that directly impacts the current trade. The code features explicit garbage collection (array.pop and delete loops) to safely purge old objects, ensuring the latest market structure is always projected stably without rendering bugs.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (C) ALT_analyst

//@version=6
indicator("Cyber Matrix [Spatial Sync]", overlay=true, max_polylines_count=100, max_lines_count=500, max_boxes_count=100, max_labels_count=500)

// ~~ Constants {
const string HUD_T = "[ MATRIX SYNC ]"
const string GRP_SYS = " [ SYSTEM & PROFILE ] "
const string TITLE_HUD = "System Name"
const string TITLE_SIZE = "Text Size"
const string TITLE_ROW = "VP Horizontal Rows (Resolution)"
const string TITLE_WMAX = "Text Max Width (Columns)"
const string TITLE_SHIST = "Project VP Histogram (Boxes) in Background"
const string TITLE_VPW = "VP Histogram Width Ratio (0.1~1.0)"
const string TITLE_RSI = "RSI Length"

const string GRP_BG = " [ HUD BACKDROP ] "
const string TITLE_SBG = "Show HUD Background Panel"
const string TITLE_BGC = "Background Panel Color (Deep Black)"
const string TITLE_BGW = "Background Panel Width (Bars)"
const string TITLE_BGP = "Background Panel Vertical Padding"

const string GRP_GEO = " [ GEOMETRY & ANCHOR ] "
const string OPT_PIVOT = "Auto Pivot (Lock to Swings)"
const string OPT_ROLL = "Rolling Lookback (Trail Price)"
const string OPT_STEP = "Step Profile (Fixed Interval Archives)"
const string TITLE_AMOD = "Geometry Anchor Mode"
const string TITLE_STEP = "Step Interval (Bars)"
const string TITLE_PROF = "Step Archive Count (Max 5)"
const string TITLE_LKBK = "Rolling Lookback Length"
const string TITLE_SWNG = "Auto Pivot Swing Length"
const string TITLE_POSX = "HUD X-Axis Offset (Bars from Anchor)"

const string GRP_MAD = " [ CYBER THEME & COLOR ] "
const string TITLE_EMA = "EMA Length (Trend Filter)"
const string TITLE_CBUL = "Neon Cyan (Bullish)"
const string TITLE_CBER = "Neon Magenta (Bearish)"
const string TITLE_GTRN = "Grid Transparency"
const string TITLE_GLOW = "Glow Transparency"

const string GRP_TOG = " [ GEOMETRY TOGGLES ] "
const string TITLE_SHEX = "Show Hexagon Matrix"
const string TITLE_SCIR = "Show Fibonacci Circle"
const string TITLE_EXTL = "Extend Horizontal Lines & Channels Right"
const string TITLE_EXTC = "Show Parallel Channels"
const string TITLE_SFIB = "Show Fibonacci Retracements"

const string GRP_MATH = " [ MATH LABELS ] "
const string TITLE_SMTH = "Show Math Formulas"
const string TITLE_MSIZ = "Label Size"

const string GRP_TRADE = " [ TRADING FUNCTION ] "
const string TITLE_SSIG = "Show Confluence Signals"

// Tooltips
const string TT_HUD  = "Text displayed at the top of the HUD panel."
const string TT_SIZE = "Adjusts the size of all text in the HUD panel."
const string TT_ROW  = "Number of price tiers for the Volume Profile. Higher values give finer detail."
const string TT_WMAX = "Maximum character width for the text-based volume profile and momentum pulse."
const string TT_SHIST = "Displays the volume profile as background boxes behind the price action."
const string TT_VPW  = "Adjusts the horizontal width of the background volume profile."
const string TT_RSI  = "Lookback length for the RSI used in momentum calculations and coloring."

const string TT_SBG  = "Toggles the dark backdrop panel behind the HUD text."
const string TT_BGC  = "Sets the color and transparency of the HUD background panel."
const string TT_BGW  = "Width of the background panel in bars."
const string TT_BGP  = "Vertical padding for the HUD background panel."

const string TT_AMOD = "Determines how the calculation window is anchored. Pivot locks to swing points, Rolling trails current price, Step creates fixed historical blocks."
const string TT_STEP = "Size of each block in bars when using Step Profile mode."
const string TT_PROF = "Number of historical step profiles to display (requires Step Profile mode)."
const string TT_LKBK = "Lookback length in bars when using Rolling Lookback mode."
const string TT_SWNG = "Lookback length for detecting major pivot highs and lows in Auto Pivot mode."
const string TT_POSX = "Shifts the entire HUD text panel left or right."

const string TT_EMA  = "Lookback length for the trend-filtering EMA. Determines bullish/bearish system state."
const string TT_CBUL = "Primary color used when price is above the EMA."
const string TT_CBER = "Primary color used when price is below the EMA."
const string TT_GTRN = "Transparency level for background grid lines and boxes."
const string TT_GLOW = "Transparency level for the glowing geometric shapes."

const string TT_SHEX = "Toggles the hexagonal geometry overlay."
const string TT_SCIR = "Toggles the Fibonacci circle geometry overlay."
const string TT_EXTL = "Extends the bounding box lines indefinitely to the right."
const string TT_EXTC = "Draws dashed mid-lines within the profile bounding box."
const string TT_SFIB = "Draws Fibonacci retracement levels (0.382, 0.5, 0.618) inside the profile."

const string TT_SMTH = "Displays the mathematical formulas driving the geometry."
const string TT_MSIZ = "Size of the math formula and Fibonacci labels."

const string TT_SSIG = "Displays buy/sell triangle markers based on trend, RSI crossovers, and price action."
//~~~~~}

// ~~ Inputs {
string hud_title = input.string(HUD_T, TITLE_HUD, group=GRP_SYS, tooltip=TT_HUD)
string hud_size = input.string(size.small, TITLE_SIZE, options=[size.tiny, size.small, size.normal, size.large], group=GRP_SYS, tooltip=TT_SIZE)
int row_count = input.int(35, TITLE_ROW, minval=10, maxval=100, group=GRP_SYS, tooltip=TT_ROW)
int max_width = input.int(35, TITLE_WMAX, group=GRP_SYS, tooltip=TT_WMAX)
bool show_hist = input.bool(true, TITLE_SHIST, group=GRP_SYS, tooltip=TT_SHIST)
float vp_width = input.float(0.3, TITLE_VPW, step=0.1, group=GRP_SYS, tooltip=TT_VPW)
int rsi_len = input.int(14, TITLE_RSI, group=GRP_SYS, tooltip=TT_RSI)

bool show_bg = input.bool(true, TITLE_SBG, group=GRP_BG, tooltip=TT_SBG)
color bg_panel_col = input.color(color.new(#0A0E17, 40), TITLE_BGC, group=GRP_BG, tooltip=TT_BGC)
int bg_width = input.int(50, TITLE_BGW, minval=10, group=GRP_BG, tooltip=TT_BGW)
float bg_pad_y = input.float(1.5, TITLE_BGP, step=0.1, group=GRP_BG, tooltip=TT_BGP)

string anchor_mode = input.string(OPT_STEP, TITLE_AMOD, options=[OPT_PIVOT, OPT_ROLL, OPT_STEP], group=GRP_GEO, tooltip=TT_AMOD)
int step_len = input.int(150, TITLE_STEP, group=GRP_GEO, tooltip=TT_STEP)
int profile_count = input.int(3, TITLE_PROF, minval=1, maxval=5, group=GRP_GEO, tooltip=TT_PROF)
int lookback = input.int(150, TITLE_LKBK, group=GRP_GEO, tooltip=TT_LKBK)
int swing_len = input.int(60, TITLE_SWNG, minval=10, group=GRP_GEO, tooltip=TT_SWNG)
int pos_x = input.int(10, TITLE_POSX, minval=-1000, maxval=1000, group=GRP_GEO, tooltip=TT_POSX)

int ema_len = input.int(34, TITLE_EMA, group=GRP_MAD, tooltip=TT_EMA)
color c_bull = input.color(color.rgb(0, 229, 255), TITLE_CBUL, group=GRP_MAD, tooltip=TT_CBUL)
color c_bear = input.color(color.rgb(255, 0, 255), TITLE_CBER, group=GRP_MAD, tooltip=TT_CBER)
int grid_trans = input.int(60, TITLE_GTRN, group=GRP_MAD, tooltip=TT_GTRN)
int glow_trans = input.int(80, TITLE_GLOW, group=GRP_MAD, tooltip=TT_GLOW)

bool show_hex = input.bool(true, TITLE_SHEX, group=GRP_TOG, tooltip=TT_SHEX)
bool show_circ = input.bool(false, TITLE_SCIR, group=GRP_TOG, tooltip=TT_SCIR)
bool ext_line = input.bool(true, TITLE_EXTL, group=GRP_TOG, tooltip=TT_EXTL)
bool ext_chan = input.bool(true, TITLE_EXTC, group=GRP_TOG, tooltip=TT_EXTC)
bool show_fib = input.bool(true, TITLE_SFIB, group=GRP_TOG, tooltip=TT_SFIB)

bool show_math = input.bool(true, TITLE_SMTH, group=GRP_MATH, tooltip=TT_SMTH)
string math_size = input.string(size.tiny, TITLE_MSIZ, options=[size.tiny, size.small, size.normal, size.large], group=GRP_MATH, tooltip=TT_MSIZ)

bool show_sig = input.bool(true, TITLE_SSIG, group=GRP_TRADE, tooltip=TT_SSIG)
//~~~~~}

// ~~ Helpers {
var array<polyline> geo_polys = array.new<polyline>()
var array<line> geo_lines = array.new<line>()
var array<box> vp_boxes = array.new<box>()
var array<label> hud_labels = array.new<label>()

f_draw_fib_circle(float fib_ratio, color col_m, color col_g, float cx, float cy, float rx, float ry) =>
    array<chart.point> pts = array.new<chart.point>()
    array<chart.point> pts_glow = array.new<chart.point>()
    for i = 0 to 72
        float angle = i * (math.pi / 36)
        int p_x = math.round(cx + (rx * fib_ratio) * math.cos(angle))
        float p_y = cy + (ry * fib_ratio) * math.sin(angle)
        array.push(pts, chart.point.from_index(p_x, p_y))
        array.push(pts_glow, chart.point.from_index(p_x, p_y))
    array.push(geo_polys, polyline.new(points=pts, line_color=col_m, line_width=2))
    array.push(geo_polys, polyline.new(points=pts_glow, line_color=col_g, line_width=6))

f_draw_hexagon(color col_m, color col_g, float cx, float cy, float rx, float ry) =>
    array<chart.point> pts_hex = array.new<chart.point>()
    array<chart.point> pts_glow = array.new<chart.point>()
    for i = 0 to 6
        float angle = i * (math.pi / 3.0) - (math.pi / 2.0)
        int p_x = math.round(cx + rx * math.cos(angle))
        float p_y = cy + ry * math.sin(angle)
        array.push(pts_hex, chart.point.from_index(p_x, p_y))
        array.push(pts_glow, chart.point.from_index(p_x, p_y))
    array.push(geo_polys, polyline.new(points=pts_hex, line_color=col_m, line_width=2))
    array.push(geo_polys, polyline.new(points=pts_glow, line_color=col_g, line_width=8))

f_draw_bracket(int x, float y, int dx, float dy, color col) =>
    array.push(geo_lines, line.new(x, y, x + dx, y, color=col, width=2))
    array.push(geo_lines, line.new(x, y, x, y + dy, color=col, width=2))
//~~~~~}

// ~~ Calculation & Drawing {
float current_rsi = ta.rsi(close, rsi_len)
float madrid_ema = ta.ema(close, ema_len)
bool is_bullish = close >= madrid_ema
color sys_color = is_bullish ? c_bull : c_bear

// Global pre-calculation for crossovers and rolling levels to prevent local scope state errors
bool is_cross_up = ta.crossover(current_rsi, 40)
bool is_cross_dn = ta.crossunder(current_rsi, 60)
float global_highest = ta.highest(high, lookback)
float global_lowest  = ta.lowest(low, lookback)

bool long_signal = show_sig and is_bullish and is_cross_up and (close > open)
bool short_signal = show_sig and not is_bullish and is_cross_dn and (close < open)

plotshape(long_signal, style=shape.triangleup, location=location.belowbar, color=c_bull, size=size.small)
plotshape(short_signal, style=shape.triangledown, location=location.abovebar, color=c_bear, size=size.small)

var float v_high = na
var int v_h_idx = na
var float v_low = na
var int v_l_idx = na

int pivot_len = math.max(5, math.round(swing_len / 2))
float ph = ta.pivothigh(high, pivot_len, pivot_len)
float pl = ta.pivotlow(low, pivot_len, pivot_len)

if anchor_mode == OPT_PIVOT
    if not na(ph)
        v_high := ph
        v_h_idx := bar_index - pivot_len
    if not na(pl)
        v_low := pl
        v_l_idx := bar_index - pivot_len

int loop_count = anchor_mode == OPT_STEP ? profile_count : 1

if barstate.islast
    while array.size(geo_polys) > 0
        polyline.delete(array.shift(geo_polys))
    while array.size(geo_lines) > 0
        line.delete(array.shift(geo_lines))
    while array.size(vp_boxes) > 0
        box.delete(array.shift(vp_boxes))
    while array.size(hud_labels) > 0
        label.delete(array.shift(hud_labels))

    for p_idx = 0 to loop_count - 1
        float top_y = na
        float bot_y = na
        int left_x = na
        int right_x = bar_index
        
        if anchor_mode == OPT_STEP
            right_x := bar_index - (p_idx * step_len)
            left_x  := math.max(0, bar_index - ((p_idx + 1) * step_len))
            float tmp_max = -999999.0
            float tmp_min = 999999.0
            if right_x > left_x
                for i = (bar_index - right_x) to (bar_index - left_x - 1)
                    tmp_max := math.max(tmp_max, high[i])
                    tmp_min := math.min(tmp_min, low[i])
                top_y := tmp_max
                bot_y := tmp_min
        else if anchor_mode == OPT_ROLL
            top_y := global_highest
            bot_y := global_lowest
            left_x := bar_index - lookback
        else
            top_y := v_high
            bot_y := v_low
            left_x := math.min(nz(v_h_idx, bar_index), nz(v_l_idx, bar_index))
            right_x := math.max(nz(v_h_idx, bar_index), nz(v_l_idx, bar_index))

        if not na(top_y) and not na(bot_y) and left_x < right_x
            int offset = bar_index - right_x
            bool local_bull = close[offset] >= madrid_ema[offset]
            color local_sys_col = local_bull ? c_bull : c_bear
            
            float ry = (top_y - bot_y) / 2.0
            float rx = (right_x - left_x) / 2.0
            float cy = bot_y + ry
            float cx = left_x + rx
            float sin45 = 0.707106
            color col_geo_main = color.new(local_sys_col, 10)
            color col_geo_glow = color.new(local_sys_col, glow_trans)
            color col_geo_grid = color.new(local_sys_col, grid_trans)
            float dynamic_offset = (top_y - bot_y) * 0.1

            float vp_step = (top_y - bot_y) / row_count
            float[] vol_bins = array.new_float(row_count, 0.0)
            float[] rsi_vol_bins = array.new_float(row_count, 0.0)
            
            if vp_step > 0
                for i = (bar_index - right_x) to (bar_index - left_x - 1)
                    float c_price = close[i]
                    float c_vol = volume[i] > 0 ? volume[i] : 1.0
                    float c_rsi = current_rsi[i]
                    int bin_idx = math.floor((c_price - bot_y) / vp_step)
                    bin_idx := math.max(0, math.min(row_count - 1, bin_idx))
                    array.set(vol_bins, bin_idx, array.get(vol_bins, bin_idx) + c_vol)
                    array.set(rsi_vol_bins, bin_idx, array.get(rsi_vol_bins, bin_idx) + (c_rsi * c_vol))
                    
            float m_vol = math.max(1.0, array.max(vol_bins))
            int poc_idx = array.indexof(vol_bins, array.max(vol_bins))
            int max_vp_bars = math.max(5, math.round((right_x - left_x) * vp_width))

            array.push(vp_boxes, box.new(left_x, top_y, right_x, bot_y, border_color=col_geo_grid, border_width=2, bgcolor=color.new(color.white, 100)))
            
            int c_x = math.round((right_x - left_x) * 0.05)
            float c_y = (top_y - bot_y) * 0.05
            f_draw_bracket(left_x, top_y, c_x, -c_y, col_geo_main)
            f_draw_bracket(right_x, top_y, -c_x, -c_y, col_geo_main)
            f_draw_bracket(left_x, bot_y, c_x, c_y, col_geo_main)
            f_draw_bracket(right_x, bot_y, -c_x, c_y, col_geo_main)
            
            string l_ext = (ext_line and p_idx == 0) ? extend.right : extend.none
            array.push(geo_lines, line.new(left_x, bot_y, right_x, top_y, color=col_geo_main, width=2, extend=l_ext))
            
            if ext_chan
                array.push(geo_lines, line.new(left_x, bot_y + ry, right_x, top_y + ry, color=col_geo_grid, style=line.style_dashed, width=1, extend=l_ext))
                array.push(geo_lines, line.new(left_x, bot_y - ry, right_x, top_y - ry, color=col_geo_grid, style=line.style_dashed, width=1, extend=l_ext))
                
            if show_hex 
                f_draw_hexagon(col_geo_main, col_geo_glow, cx, cy, rx, ry)
            if show_circ
                f_draw_fib_circle(1.0, col_geo_main, col_geo_glow, cx, cy, rx, ry)
                f_draw_fib_circle(0.618, col_geo_main, col_geo_glow, cx, cy, rx, ry)
                
            if show_fib
                array<float> fib_lvls = array.from(0.382, 0.5, 0.618)
                for f in fib_lvls
                    float fp = bot_y + (top_y - bot_y) * f
                    array.push(geo_lines, line.new(left_x, fp, right_x + 10, fp, color=col_geo_grid, style=line.style_dotted, extend=l_ext))
                    array.push(hud_labels, label.new(right_x + 10, fp, str.tostring(f) + " RT", textcolor=col_geo_main, style=label.style_none, size=math_size))

            float price_618_up = cy + (ry * 0.618 * sin45)
            array.push(geo_lines, line.new(left_x, price_618_up, right_x + 15, price_618_up, color=col_geo_main, style=line.style_solid, width=2, extend=l_ext))
            array.push(hud_labels, label.new(right_x + 15, price_618_up, "0.618 <SYNC>", textcolor=col_geo_main, style=label.style_none, size=math_size))

            if show_math
                array.push(hud_labels, label.new(left_x, top_y + dynamic_offset, "[ Matrix_E_Space ]\nE(t) = [xmin, ymax; xmax, ymin]", style=label.style_none, textcolor=col_geo_grid, size=math_size, textalign=text.align_left))
                array.push(hud_labels, label.new(right_x, bot_y - dynamic_offset, "[ Hexagonal_Matrix ]\nPerfect Packing | n = 6", style=label.style_none, textcolor=col_geo_grid, size=math_size, textalign=text.align_right))

            int base_x = left_x + pos_x

            if show_bg
                float bg_top = top_y + (dynamic_offset * bg_pad_y)
                float bg_bot = bot_y - (dynamic_offset * bg_pad_y)
                array.push(vp_boxes, box.new(base_x - 2, bg_top, base_x + bg_width, bg_bot, border_color=na, bgcolor=bg_panel_col))

            string mode_txt = p_idx == 0 ? "CURRENT" : "ARCHIVE " + str.tostring(p_idx)
            string status_txt = local_bull ? "OVERRIDE (CYAN)" : "WARNING (MAGENTA)"
            string str_head = hud_title + " [" + mode_txt + "]\nSTATUS: " + status_txt + "\n======================================"
            array.push(hud_labels, label.new(base_x, top_y + dynamic_offset, str_head, color=color.new(color.white, 100), textcolor=local_sys_col, style=label.style_label_left, text_font_family=font.family_monospace, size=hud_size))

            for i = 0 to row_count - 1
                float bin_vol = array.get(vol_bins, i)
                float avg_rsi = bin_vol > 0 ? (array.get(rsi_vol_bins, i) / bin_vol) : 50.0
                
                float bin_top = bot_y + (i * vp_step) + vp_step
                float bin_bot = bot_y + (i * vp_step)
                float center_y = bin_bot + (vp_step / 2)
                
                if show_hist and bin_vol > 0
                    int bar_w = math.round((bin_vol / m_vol) * max_vp_bars)
                    int trans = avg_rsi >= 60 ? 50 : (avg_rsi <= 40 ? 80 : 70)
                    color box_col = color.new(local_sys_col, trans)
                    
                    if i == poc_idx
                        box_col := color.new(local_sys_col, 20)
                        array.push(geo_lines, line.new(left_x, center_y, right_x + 15, center_y, color=local_sys_col, style=line.style_dotted, width=2))
                        
                    array.push(vp_boxes, box.new(left_x, bin_top, left_x + bar_w, bin_bot, border_color=na, bgcolor=box_col))

                int num_blocks = math.round((bin_vol / m_vol) * max_width)
                string block_char = avg_rsi >= 60 ? "█" : (avg_rsi <= 40 ? "░" : "▒")
                string price_str = (i == poc_idx ? ">" : " ") + str.tostring(bin_bot, format.mintick)
                string blocks_str = num_blocks > 0 ? str.repeat(block_char, num_blocks) : ""
                
                array.push(hud_labels, label.new(base_x, center_y, price_str + " | " + blocks_str, color=color.new(color.white, 100), textcolor=local_sys_col, style=label.style_label_left, text_font_family=font.family_monospace, size=hud_size))

            string str_temp = "======================================\n ■ TEMPORAL MOMENTUM (Pulse)\n--------------------------------------\n"
            float[] r_rsi = array.new_float(max_width, 0.0)
            for i = 0 to max_width - 1
                int hist_idx = offset + max_width - 1 - i
                float r_val = 50.0
                if hist_idx >= 0 and hist_idx < 100000
                    r_val := current_rsi[hist_idx]
                array.set(r_rsi, i, r_val)
            for r = 4 to 1
                string line_str = (r == 4 ? " OB | " : r == 3 ? " 60 | " : r == 2 ? " 40 | " : " OS | ")
                for i = 0 to max_width - 1
                    float n = (array.get(r_rsi, i) / 100.0) * 4.0
                    line_str += (n >= r ? "█" : n >= r - 0.5 ? "▄" : " ")
                str_temp += line_str + "\n"
                
            array.push(hud_labels, label.new(base_x, bot_y - dynamic_offset, str_temp, color=color.new(color.white, 100), textcolor=local_sys_col, style=label.style_label_left, text_font_family=font.family_monospace, size=hud_size))
//~~~~~}
````
