# MARs - Moving Average Ribbon Scirocco

- url: https://www.tradingview.com/script/XypffRTi-MARs-Moving-Average-Ribbon-Scirocco/
- type: indicator
- pine_id: PUB;4ee83c598a6345d780694db54e560dd0
- version: 4.0

## Description

Initially, I decided to build this indicator simply to bundle multiple moving averages together under a single script to save chart space. However, I chose to completely overhaul and improve the design to transform it into an institutional-grade, multi-timeframe trend visualization and analysis system.

Optimized for dark-theme chart layouts and named after the high-velocity, dust-carrying desert windstorms, the Moving Average Ribbon Scirocco (MARs) unifies independent multi-timeframe data structures, directional price momentum, and volume-weighted confirmation thresholds into a single, cohesive channel overlay.

Why MARs is Useful

- Eliminates Screen Flipping: Traditional charting ribbons require constant switching between multiple chart intervals to stay aligned with the dominant trend. MARs solves this by anchoring independent timeframe inputs to each of the four moving averages individually. This allows you to track multiple higher-timeframe macro baselines (like 4-hour, Daily, or Weekly trends) directly on a lower execution chart (like a 1-minute or 5-minute chart) without constantly changing screens or splitting your workspace.

- Absolute Momentum Slope Vectoring: MARs circumvents this by ditching screen-based spatial positioning entirely. Instead, it utilizes absolute slope momentum vectors calculated through sequential ta.rising() and ta.falling() states on the underlying series. This mathematical approach guarantees that the directional colors remain locked to their true momentum axes regardless of how high or low your active chart grid is scaled.

- Fixes Color Inversions: Standard multi-timeframe ribbons rely on a simple visual overlay, which causes the colors to flip backwards or invert when you move to a higher chart interval due to historical bar compression. MARs isolates momentum trends at their native calculation source to keep color maps perfectly accurate on all scales.

What Makes It Unique

- Persistent Visual Framework: Standard ribbons break or return an na element the moment a user toggles a single line off in the settings menu. MARs solves this via a dynamic boundary engine built with algorithmic math.max() and math.min() arrays paired with non-zero element converters (nz()).

- Adaptive Anchor Logic: The indicator reads your active user checkbox selections bar-by-bar in real-time; if you hide individual moving averages to clean up your workspace, the background cloud instantly re-anchors itself to the next closest visible line, keeping the channel fill functional.

- Universal Asset Compatibility: Standard indicators with volume-weighted elements crash or turn completely invisible when applied to assets that lack native volume tracking data (such as Forex spot pairs, Crypto CFDs, Commodities, or indices like SPX).

- Volume Safety Net: MARs features an automated volume safety-net mechanism that samples a 10-period smoothing filter. If it detects zero volume, the script instantly bypasses the volume engine and defaults to a stable, visible base opacity, providing a seamless analysis experience across all financial asset classes.

Finding Your Own Way to Use It

- No Rigid Signals: Because MARs was explicitly engineered without rigid, pre-programmed "buy/sell" arrow signals or directional labels, it does not dictate how you must trade.

- Discover Your Own Edge: The true value of the indicator comes from discovering your own systematic edge through a personalized combination of moving average styles (SMA, EMA, SMMA, WMA, or VWMA), customized lengths, and specific timeframe steps.

- Objective Toolkit: By stripping away prescriptive text and leaving interpretation to the trader, MARs functions as an objective diagnostic toolkit that can be customized for short-term intraday momentum scalping, long-term swing trading, or indicator-on-indicator sourcing.

Core Functionality

- Dual-State Volume Confirmation Engine: Evaluates price expansion against a 20-period simple moving average of volume. The background channel instantly brightens into high-visibility thermal colors when structural expansion is backed by institutional volume, and automatically mutes its opacity when volume drops below average to warn you of low-participation breakouts.

- Anti-Repaint Protective Framework: Technical calculation loops are isolated inside encapsulated function blocks via request.security() with barmerge.lookahead_off. This guarantees that your historical chart lines are locked into place exactly as they appeared in real-time, eliminating future-data leaking and data distortion.

- Achromatic Martian Thermal Palette: Designed specifically to reduce eye strain and eliminate visual fatigue during long trading sessions on dark background layouts. The moving average lines form a clean, static gradient, while the background fill shifts between Vibrant Solar Gold, Martian Core Orange, and Molten Crimson Red, fading completely into a dark Obsidian Gray mask to tell you exactly when the market has flattened out into a tight consolidation squeeze.

Fully Customizable Theme: If you are not satisfied with these default theme selections, the color scheme remains fully customizable, allowing you to re-map both the individual lines and the background cloud states via the TradingView interface to match your exact visual preference.

Conclusion

The Moving Average Ribbon Scirocco (MARs) marks a complete overhaul of traditional charting ribbons, transforming a standard space-saving bundle into a robust, multi-timeframe trend analysis system. By filtering noise through volume validation, securing lines against historical repainting, and utilizing absolute slope vectors to permanently prevent color inversions, the indicator delivers an objective, mathematically precise overview of the market.

Ultimately, MARs serves as a versatile, high-contrast diagnostic toolkit designed to integrate cleanly into your workspace, giving you the freedom to build, refine, and execute your own systematic trading edge.

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon Scirocco", shorttitle = "MARs", overlay = true, timeframe = "", timeframe_gaps = true)

// ========================================================================= //
// INDICATOR: Moving Average Ribbon Scirocco (MARs)                         //
// AUTHOR: Capitalist_Zach                                                   //
// ========================================================================= //

// ==========================================
// // 1. GLOBAL USER CONFIGURATIONS
// ==========================================
// Visual Configuration Group: Sets up the user interface grouping layout.
g_visual = "Visual Properties"

// Show Higher Timeframe Gaps: Dictates whether higher timeframe data merges with 
// visual continuity (false) or preserves strict historical block steps on the chart (true).
gaps_setting = input.bool(true, title="Show Higher Timeframe Gaps", group=g_visual)

// Enable Volume Filter: Operational toggle. Confirms structural trend expansions by 
// increasing ribbon color intensity when active transaction volume prints above its baseline.
use_vol_filter = input.bool(true, title="Enable Volume Filter", group=g_visual)

// Volume Average Length: Sets the lookback horizon for the volume filter. Higher values 
// smooth out sudden volume anomalies, ensuring only sustained participation alters ribbon intensity.
vol_length = input.int(20, title="Volume Average Length", group=g_visual, minval=1)

// Master Line Selector: Allows the user to choose which moving average dictates the core trend logic.
master_ma_selection = input.string("MA #1", title="Master Trend Line", group=g_visual, options=["MA #1", "MA #2", "MA #3", "MA #4"])

// ==========================================
// // 2. CORE DATA LOGIC PIPELINE
// ==========================================
// Moving Average Selector Matrix: Functional switch block routing standard inputs 
// directly into specialized built-in Pine Script smoothing algorithms.
get_ma(src, len, ma_type) =>
    switch ma_type
        "SMA"         => ta.sma(src, len)
        "EMA"         => ta.ema(src, len)
        "SMMA (RMA)"  => ta.rma(src, len)
        "WMA"         => ta.wma(src, len)
        "VWMA"        => ta.vwma(src, len)
        => na

// Multi-Timeframe Fetch Wrapper: Orchestrates external resolution calls. Pairs the 
// selected gap strategy with lookahead protection to guarantee non-repainting historical bars.
// Fixnan Wrap: Prevents runtime trend evaluation failure by filling data gaps with the last known valid state.
request_smart_ma(tf, src, len, ma_type, use_gaps) =>
    gap_strategy = use_gaps ? barmerge.gaps_on : barmerge.gaps_off
    raw_ma = request.security(syminfo.tickerid, tf, get_ma(src, len, ma_type), gap_strategy, barmerge.lookahead_off)
    fixnan(raw_ma)

// ==========================================
// // 3. INDIVIDUAL ROW INPUTS & EXECUTION MATRIX
// ==========================================
// Moving Average Row 1 Configuration & Execution Sequence: Tracks short-term velocity.
show_ma1   = input.bool(true, "MA #1", inline = "MA #1")
ma1_type   = input.string("SMA", "", inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input.source(close, "", inline = "MA #1", active = show_ma1)
ma1_length = input.int(20, "", inline = "MA #1", active = show_ma1, minval = 1)
ma1_tf     = input.timeframe("", "", inline = "MA #1", active = show_ma1)
ma1_color  = input.color(#ffb703, "", inline = "MA #1", active = show_ma1)
ma1_sec    = request_smart_ma(ma1_tf, ma1_source, ma1_length, ma1_type, gaps_setting)
ma1        = show_ma1 ? ma1_sec : na

// Moving Average Row 2 Configuration & Execution Sequence: Tracks minor trend structural changes.
show_ma2   = input.bool(true, "MA #2", inline = "MA #2")
ma2_type   = input.string("SMA", "", inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input.source(close, "", inline = "MA #2", active = show_ma2)
ma2_length = input.int(50, "", inline = "MA #2", active = show_ma2, minval = 1)
ma2_tf     = input.timeframe("", "", inline = "MA #2", active = show_ma2)
ma2_color  = input.color(#f15bb5, "", inline = "MA #2", active = show_ma2)
ma2_sec    = request_smart_ma(ma2_tf, ma2_source, ma2_length, ma2_type, gaps_setting)
ma2        = show_ma2 ? ma2_sec : na

// Moving Average Row 3 Configuration & Execution Sequence: Tracks intermediate trend structural changes.
show_ma3   = input.bool(true, "MA #3", inline = "MA #3")
ma3_type   = input.string("SMA", "", inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input.source(close, "", inline = "MA #3", active = show_ma3)
ma3_length = input.int(100, "", inline = "MA #3", active = show_ma3, minval = 1)
ma3_tf     = input.timeframe("", "", inline = "MA #3", active = show_ma3)
ma3_color  = input.color(#4a4e69, "", inline = "MA #3", active = show_ma3)
ma3_sec    = request_smart_ma(ma3_tf, ma3_source, ma3_length, ma3_type, gaps_setting)
ma3        = show_ma3 ? ma3_sec : na

// Moving Average Row 4 Configuration & Execution Sequence: Tracks macro trend structural changes.
show_ma4   = input.bool(true, "MA #4", inline = "MA #4")
ma4_type   = input.string("SMA", "", inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input.source(close, "", inline = "MA #4", active = show_ma4)
ma4_length = input.int(200, "", inline = "MA #4", active = show_ma4, minval = 1)
ma4_tf     = input.timeframe("", "", inline = "MA #4", active = show_ma4)
ma4_color  = input.color(#212529, "", inline = "MA #4", active = show_ma4)
ma4_sec    = request_smart_ma(ma4_tf, ma4_source, ma4_length, ma4_type, gaps_setting)
ma4        = show_ma4 ? ma4_sec : na

// ==========================================
// // 4. FILTER MATRICES & DYNAMIC VECTOR MATHEMATICS
// ==========================================
// Volume Capture: Pulls actual volume values while using nz() to assign 0 on instruments with no data feed.
chart_volume = nz(volume)

// Volume Baseline: Computes the standard moving average baseline of volume distribution over time.
vol_avg = ta.sma(chart_volume, vol_length)

// Asset Volume Check: Verifies if the asset completely lacks liquid volume metrics (e.g., certain Forex pairs, indices).
has_no_volume = ta.sma(chart_volume, 10) == 0

// Momentum Volume Confirmation: Confirms whether a current price swing is backed by a surge in transaction activity.
vol_confirmed = not use_vol_filter or has_no_volume or (chart_volume > vol_avg)

// Boundary Extraction Engine: Dynamically indexes the highest and lowest enabled moving averages to 
// establish the macro ribbon channel. This prevents code breakdown if intermediate rows are disabled.
valid_ma1 = show_ma1 ? ma1 : (show_ma2 ? ma2 : (show_ma3 ? ma3 : ma4))
valid_ma4 = show_ma4 ? ma4 : (show_ma3 ? ma3 : (show_ma2 ? ma2 : ma1))

/// Dynamic Master Line Resolver: Routes the selected MA to the tracking engine, applying visibility fallbacks.
master_ma = switch master_ma_selection
    "MA #1" => show_ma1 ? ma1 : valid_ma1
    "MA #2" => show_ma2 ? ma2 : valid_ma1
    "MA #3" => show_ma3 ? ma3 : valid_ma1
    "MA #4" => show_ma4 ? ma4 : valid_ma4
    => valid_ma1

// Market Regime Tracking: Evaluates the direction of the chosen master line's vector slope.
state_alpha = ta.rising(master_ma, 1)
state_beta  = ta.falling(master_ma, 1)

// ==========================================
// // 5. DYNAMIC RIBBON CHANNEL FENCE ENGINE
// ==========================================
// Dynamic Matrix Extrema: Tracks the exact outer geographical boundaries of the ribbon across all visible lines.
cloud_max = math.max(nz(ma1, -999999), nz(ma2, -999999), nz(ma3, -999999), nz(ma4, -999999))
cloud_min = math.min(nz(ma1, 999999), nz(ma2, 999999), nz(ma3, 999999), nz(ma4, 999999))

// Anchor Fallbacks: Replaces uninitialized mathematical values with a clear 'na' reference state.
final_max = cloud_max == -999999 ? na : cloud_max
final_min = cloud_min == 999999 ? na : cloud_min

// Regime Classification Matrix: Determines trend bias based on the slope of the master tracking line. 
// Applies high-contrast alpha overlays when volume confirms a trend expansion, and desaturated tones during low-liquidity drift.
var color ribbon_fill_color = na
if state_alpha
    ribbon_fill_color := vol_confirmed ? color.new(#fb8500, 75) : color.new(#e67e22, 88)
else if state_beta
    ribbon_fill_color := vol_confirmed ? color.new(#d90429, 75) : color.new(#9b2226, 88)
else
    ribbon_fill_color := color.new(#161a1d, 80)

// ==========================================
// // 6. GRAPHICAL OUTPUT PLOT GENERATION
// ==========================================
// Core Ribbon Elements: Renders actual computed lines to the screen conditionally based on user checkboxes.
plot(ma1, "MA #1", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display = show_ma4 ? display.all : display.none)

// Calculate the mathematical center line of the ribbon channel
ribbon_center = (final_max + final_min) / 2

// Hidden Boundary Targets: Generates invisible structural coordinates to guide the ribbon rendering engine.
p_max    = plot(final_max, "Ribbon Top Anchor", color=na, display=display.none)
p_center = plot(ribbon_center, "Ribbon Center Anchor", color=na, display=display.none)
p_min    = plot(final_min, "Ribbon Bottom Anchor", color=na, display=display.none)

// Setup explicit color states for the solid center core and the faded outer edges
color center_solid = na
color edge_fade    = na

if state_alpha
    center_solid := vol_confirmed ? color.new(#fb8500, 60) : color.new(#e67e22, 80)
    edge_fade    := vol_confirmed ? color.new(#fb8500, 98) : color.new(#e67e22, 99)
else if state_beta
    center_solid := vol_confirmed ? color.new(#d90429, 60) : color.new(#9b2226, 80)
    edge_fade    := vol_confirmed ? color.new(#d90429, 98) : color.new(#9b2226, 99)
else
    center_solid := color.new(#161a1d, 70)
    edge_fade    := color.new(#161a1d, 98)

// Split-Channel Fills: Independently maps gradients from the solid center to the transparent outer boundaries
fill(p_max, p_center, top_value=final_max, bottom_value=ribbon_center, top_color=edge_fade, bottom_color=center_solid, title="Upper Ribbon Gradient")
fill(p_center, p_min, top_value=ribbon_center, bottom_value=final_min, top_color=center_solid, bottom_color=edge_fade, title="Lower Ribbon Gradient")
````
