<!-- tradingview-pine-id: PUB;be7bb91b135a45fa81ec6a7b4fa4ac4d -->
<!-- tradingviewscripts-format: 1 -->
# Trend Line Methods

Source: https://www.tradingview.com/script/GsRqNT8Q-Trend-Line-Methods-TLM/

## Description

Trend Line Methods (TLM)

Overview
Trend Line Methods (TLM) is a visual study designed to help traders explore trend structure using two complementary, auto-drawn trend channels. The script focuses on how price interacts with rising or falling boundaries over time. It does not generate trade signals or manage risk; its purpose is to support discretionary chart analysis.

Method 1 – Pivot Span Trendline
The Pivot Span Trendline method builds a dynamic channel from major swing points detected by pivot highs and pivot lows.
•	The script tracks a configurable number of recent pivot highs and lows.
•	From the oldest and most recent stored pivot highs, it draws an upper trend line.
•	From the oldest and most recent stored pivot lows, it draws a lower trend line.
•	An optional filled area can be drawn between the two lines to highlight the active trend span.
As new pivots form, the lines are recalculated so that the channel evolves with market structure. This method is useful for visualising how price respects a trend corridor defined directly by swing points.

Method 2 – 5-Point Straight Channel
The 5-Point Straight Channel method approximates a straight trend channel using five key points extracted from a fixed lookback window.
Within the selected window:
•	The window is divided into five segments of similar length.
•	In each segment, the highest high is used as a representative high point.
•	In each segment, the lowest low is used as a representative low point.
•	A straight regression-style line is fitted through the five high points to form the upper boundary.
•	A second straight line is fitted through the five low points to form the lower boundary.
The result is a pair of straight lines that describe the overall directional channel of price over the chosen window. Compared to Method 1, this approach is less focused on the very latest swings and more on the broader slope of the market.

Inputs & Menus
Pivot Span Trendline group (Method 1)
•	Enable Pivot Span Trendline – Turns Method 1 on or off.
•	High trend line color / Low trend line color – Colors of the upper and lower trend lines.
•	Fill color between trend lines – Base color used to shade the area between the two lines. Transparency is controlled internally.
•	Trend line thickness – Line width for both high and low trend lines.
•	Trend line style – Line style (solid, dashed, or dotted).
•	Pivot Left / Pivot Right – Number of bars to the left and right used to confirm pivot highs and lows. Larger values produce fewer but more significant swing points.
•	Pivot Count – How many historical pivot points are kept for constructing the trend lines.
•	Lookback Length – Number of bars used to keep pivots in range and to extend the trend lines across the chart.
5-Point Straight Channel group (Method 2)
•	Enable 5-Point Straight Channel – Turns Method 2 on or off.
•	High channel line color / Low channel line color – Colors of the upper and lower channel lines.
•	Channel line thickness – Line width for both channel lines.
•	Channel line style – Line style (solid, dashed, or dotted).
•	Channel Length (bars) – Lookback window used to divide price into five segments and build the straight high/low channel.

Using Both Methods Together
Both methods are designed to visualise the same underlying idea: price tends to move inside rising or falling channels. Method 1 emphasises the most recent swing structure via pivot points, while Method 2 summarises the broader channel over a fixed window.
When the Pivot Span Trendline corridor and the 5-Point Straight Channel boundaries align or intersect, they can highlight zones where multiple ways of drawing trend lines point to similar support or resistance areas. Traders can use these confluence zones as a visual reference when planning their own entries, exits, or risk levels, according to their personal trading plan.

Notes
•	This script is meant as an educational and analytical tool for studying trend lines and channels.
•	It does not generate trading signals and does not replace independent analysis or risk management.
•	The behaviour of both methods is timeframe- and symbol-agnostic; they will adapt to whichever chart you apply them to.

---

## Source Code

````pine
//@version=6
indicator(title="Trend Line Methods", shorttitle="TLM", overlay=true)

//══════════════
// Pivot Span Trendline — Method Switch & Group (Method 1)
//══════════════
string grpPivotSpan = "Pivot Span Trendline"

bool enable_pivot_span_trendline = input.bool(
     defval  = true,
     title   = "Enable Pivot Span Trendline",
     tooltip = "Toggle the Pivot Span Trendline method on or off.",
     group   = grpPivotSpan)

//══════════════
// Style Settings (Pivot Span Trendline)
//══════════════
color trend_high_color = input.color(
     defval  = #ff7b00,
     title   = "High trend line color",
     tooltip = "Color for high trend lines.",
     group   = grpPivotSpan)

color trend_low_color = input.color(
     defval  = #ff7b00,
     title   = "Low trend line color",
     tooltip = "Color for low trend lines.",
     group   = grpPivotSpan)

// Base color for the fill area between high and low trend lines (transparency = 90 applied in code)
color pivot_span_fill_color = input.color(
     defval  = #ff7b00,
     title   = "Fill color between trend lines",
     tooltip = "Base color for the area between high and low trend lines (transparency = 90).",
     group   = grpPivotSpan)

int trend_line_width = input.int(
     defval  = 2,
     minval  = 1,
     maxval  = 5,
     title   = "Trend line thickness",
     tooltip = "Thickness of high/low trend lines.",
     group   = grpPivotSpan)

string trend_line_style = input.string(
     defval  = "dashed",
     options = ["solid", "dashed", "dotted"],
     title   = "Trend line style",
     tooltip = "Style of high/low trend lines.",
     group   = grpPivotSpan)

//══════════════
// Utils
//══════════════
get_line_style(string style) =>
    style == "solid"  ? line.style_solid  :
     style == "dashed" ? line.style_dashed :
     style == "dotted" ? line.style_dotted :
                         line.style_dashed

//══════════════
// Pivot Parameters
//══════════════
int pivot_left_input  = input.int(5,   minval=1,  title="Pivot Left",      tooltip="Left bars for pivot detection.",         group=grpPivotSpan)
int pivot_right_input = input.int(5,   minval=1,  title="Pivot Right",     tooltip="Right bars for pivot detection.",        group=grpPivotSpan)
int point_count_input = input.int(5,   minval=2,  title="Pivot Count",     tooltip="Number of pivots to track.",             group=grpPivotSpan)
int length_input      = input.int(100, minval=10, title="Lookback Length", tooltip="Bars used to keep pivots inside range.", group=grpPivotSpan)

//══════════════
// Pivot Storage
//══════════════
var int[]   high_idx_points = array.new_int()
var float[] high_val_points = array.new_float()
var int[]   low_idx_points  = array.new_int()
var float[] low_val_points  = array.new_float()

//══════════════
// Trend Lines & Fill IDs
//══════════════
var line     high_trend_line_id = na
var line     low_trend_line_id  = na
var linefill pivot_span_fill_id = na

//══════════════
// Pivot Span Trendline Logic (Method 1)
//══════════════
if enable_pivot_span_trendline
    // Pivot Detection
    float pivot_high_value = ta.pivothigh(high, pivot_left_input, pivot_right_input)
    float pivot_low_value  = ta.pivotlow(low,  pivot_left_input, pivot_right_input)

    // When a pivot high is detected, store its bar index and price.
    if not na(pivot_high_value)
        int   piv_hi_idx   = bar_index - pivot_right_input
        float piv_hi_price = high[pivot_right_input]
        array.push(high_idx_points, piv_hi_idx)
        array.push(high_val_points, piv_hi_price)
        // Remove oldest entries if exceeding the configured pivot count.
        while array.size(high_idx_points) > point_count_input
            array.shift(high_idx_points)
            array.shift(high_val_points)

    // When a pivot low is detected, store its bar index and price.
    if not na(pivot_low_value)
        int   piv_lo_idx   = bar_index - pivot_right_input
        float piv_lo_price = low[pivot_right_input]
        array.push(low_idx_points, piv_lo_idx)
        array.push(low_val_points, piv_lo_price)
        while array.size(low_idx_points) > point_count_input
            array.shift(low_idx_points)
            array.shift(low_val_points)

    // Draw or update the HIGH trend line; remove it if fewer than two high pivots exist.
    if array.size(high_idx_points) >= 2
        int   far_hi_idx   = array.get(high_idx_points, 0)
        float far_hi_val   = array.get(high_val_points, 0)
        int   near_hi_idx  = array.get(high_idx_points, array.size(high_idx_points) - 1)
        float near_hi_val  = array.get(high_val_points, array.size(high_val_points) - 1)
        int   hi_bar_diff  = near_hi_idx - far_hi_idx
        float hi_slope     = hi_bar_diff != 0 ? (near_hi_val - far_hi_val) / hi_bar_diff : 0.0
        float hi_intercept = far_hi_val - hi_slope * far_hi_idx
        int   x1_hi        = bar_index - (length_input - 1)
        int   x2_hi        = bar_index
        float y1_hi        = hi_intercept + hi_slope * x1_hi
        float y2_hi        = hi_intercept + hi_slope * x2_hi
        if na(high_trend_line_id)
            high_trend_line_id := line.new(
                 x1_hi, y1_hi, x2_hi, y2_hi,
                 xloc   = xloc.bar_index,
                 extend = extend.none,
                 color  = trend_high_color,
                 width  = trend_line_width,
                 style  = get_line_style(trend_line_style))
        else
            line.set_xy1(high_trend_line_id, x1_hi, y1_hi)
            line.set_xy2(high_trend_line_id, x2_hi, y2_hi)
            line.set_extend(high_trend_line_id, extend.none)
            line.set_color(high_trend_line_id, trend_high_color)
            line.set_width(high_trend_line_id, trend_line_width)
            line.set_style(high_trend_line_id, get_line_style(trend_line_style))
    else
        if not na(high_trend_line_id)
            line.delete(high_trend_line_id)
        high_trend_line_id := na

    // Draw or update the LOW trend line; remove it if fewer than two low pivots exist.
    if array.size(low_idx_points) >= 2
        int   far_lo_idx   = array.get(low_idx_points, 0)
        float far_lo_val   = array.get(low_val_points, 0)
        int   near_lo_idx  = array.get(low_idx_points, array.size(low_idx_points) - 1)
        float near_lo_val  = array.get(low_val_points, array.size(low_val_points) - 1)
        int   lo_bar_diff  = near_lo_idx - far_lo_idx
        float lo_slope     = lo_bar_diff != 0 ? (near_lo_val - far_lo_val) / lo_bar_diff : 0.0
        float lo_intercept = far_lo_val - lo_slope * far_lo_idx
        int   x1_lo        = bar_index - (length_input - 1)
        int   x2_lo        = bar_index
        float y1_lo        = lo_intercept + lo_slope * x1_lo
        float y2_lo        = lo_intercept + lo_slope * x2_lo
        if na(low_trend_line_id)
            low_trend_line_id := line.new(
                 x1_lo, y1_lo, x2_lo, y2_lo,
                 xloc   = xloc.bar_index,
                 extend = extend.none,
                 color  = trend_low_color,
                 width  = trend_line_width,
                 style  = get_line_style(trend_line_style))
        else
            line.set_xy1(low_trend_line_id, x1_lo, y1_lo)
            line.set_xy2(low_trend_line_id, x2_lo, y2_lo)
            line.set_extend(low_trend_line_id, extend.none)
            line.set_color(low_trend_line_id, trend_low_color)
            line.set_width(low_trend_line_id, trend_line_width)
            line.set_style(low_trend_line_id, get_line_style(trend_line_style))
    else
        if not na(low_trend_line_id)
            line.delete(low_trend_line_id)
        low_trend_line_id := na

    //══════════════
    // Pivot Span Fill Between High & Low Lines
    //══════════════
    if not na(high_trend_line_id) and not na(low_trend_line_id)
        color fill_col = color.new(pivot_span_fill_color, 90)
        if na(pivot_span_fill_id)
            pivot_span_fill_id := linefill.new(
                 high_trend_line_id,
                 low_trend_line_id,
                 fill_col)
        else
            linefill.set_color(pivot_span_fill_id, fill_col)
    else
        if not na(pivot_span_fill_id)
            linefill.delete(pivot_span_fill_id)
            pivot_span_fill_id := na
else
    // When method is disabled, make sure any existing lines and fills are removed.
    if not na(high_trend_line_id)
        line.delete(high_trend_line_id)
        high_trend_line_id := na
    if not na(low_trend_line_id)
        line.delete(low_trend_line_id)
        low_trend_line_id := na
    if not na(pivot_span_fill_id)
        linefill.delete(pivot_span_fill_id)
        pivot_span_fill_id := na

//══════════════
// 5-Point Straight Channel — Method 2
//══════════════
string grpFivePoint = "5-Point Straight Channel"

bool enable_five_point_channel = input.bool(
     defval  = true,
     title   = "Enable 5-Point Straight Channel",
     tooltip = "Toggle the 5-Point Straight Channel method on or off.",
     group   = grpFivePoint)

// Style for Method 2
color five_hi_color = input.color(
     defval  = #ff00d0,
     title   = "High channel line color",
     tooltip = "Color for the upper 5-point channel line.",
     group   = grpFivePoint)

color five_lo_color = input.color(
     defval  = #ff00d0,
     title   = "Low channel line color",
     tooltip = "Color for the lower 5-point channel line.",
     group   = grpFivePoint)

int five_line_width = input.int(
     defval  = 3,
     minval  = 1,
     maxval  = 5,
     title   = "Channel line thickness",
     tooltip = "Thickness of 5-point channel lines.",
     group   = grpFivePoint)

string five_line_style = input.string(
     defval  = "solid",
     options = ["solid", "dashed", "dotted"],
     title   = "Channel line style",
     tooltip = "Style of 5-point channel lines.",
     group   = grpFivePoint)

// Length (window) for Method 2
int len_channel_5pt = input.int(
     defval  = 100,
     minval  = 10,
     title   = "Channel Length (bars)",
     tooltip = "Lookback window used to build 5-point straight high/low channel lines.",
     group   = grpFivePoint)

//──────── Function: 5-Point Linear Channel Fit
calcFivePointChannel(int len_window) =>
    float slope_hi_5pt     = na
    float intercept_hi_5pt = na
    float slope_lo_5pt     = na
    float intercept_lo_5pt = na

    bool enough_bars_5pt = bar_index >= len_window

    if enough_bars_5pt
        float sum_x_hi  = 0.0
        float sum_y_hi  = 0.0
        float sum_xy_hi = 0.0
        float sum_x2_hi = 0.0
        int   n_hi      = 0

        float sum_x_lo  = 0.0
        float sum_y_lo  = 0.0
        float sum_xy_lo = 0.0
        float sum_x2_lo = 0.0
        int   n_lo      = 0

        int seg_len_base = math.max(1, math.floor(len_window / 5))

        for k = 0 to 4
            int seg_start = k * seg_len_base
            int remaining = len_window - seg_start
            if remaining <= 0
                break

            int seg_len_k = k < 4 ? math.min(seg_len_base, remaining) : remaining

            // High segment – take highest high in this segment
            float max_hi     = na
            int   barsAgo_hi = na
            for i = 0 to seg_len_k - 1
                int   sh = seg_start + i
                float v  = high[sh]
                if not na(v) and (na(max_hi) or v > max_hi)
                    max_hi     := v
                    barsAgo_hi := sh
            if not na(barsAgo_hi)
                int   x_hi_int = bar_index - barsAgo_hi
                float x_hi     = x_hi_int
                float y_hi     = high[barsAgo_hi]
                sum_x_hi  += x_hi
                sum_y_hi  += y_hi
                sum_xy_hi += x_hi * y_hi
                sum_x2_hi += x_hi * x_hi
                n_hi      += 1

            // Low segment – take lowest low in this segment
            float min_lo     = na
            int   barsAgo_lo = na
            for i = 0 to seg_len_k - 1
                int   sl = seg_start + i
                float v2 = low[sl]
                if not na(v2) and (na(min_lo) or v2 < min_lo)
                    min_lo     := v2
                    barsAgo_lo := sl
            if not na(barsAgo_lo)
                int   x_lo_int = bar_index - barsAgo_lo
                float x_lo     = x_lo_int
                float y_lo     = low[barsAgo_lo]
                sum_x_lo  += x_lo
                sum_y_lo  += y_lo
                sum_xy_lo += x_lo * y_lo
                sum_x2_lo += x_lo * x_lo
                n_lo      += 1

        // Linear regression for highs
        if n_hi >= 2
            float nf_hi    = n_hi
            float denom_hi = nf_hi * sum_x2_hi - sum_x_hi * sum_x_hi
            slope_hi_5pt     := denom_hi != 0.0 ? (nf_hi * sum_xy_hi - sum_x_hi * sum_y_hi) / denom_hi : 0.0
            intercept_hi_5pt := nf_hi  != 0.0 ? (sum_y_hi - slope_hi_5pt * sum_x_hi) / nf_hi : na

        // Linear regression for lows
        if n_lo >= 2
            float nf_lo    = n_lo
            float denom_lo = nf_lo * sum_x2_lo - sum_x_lo * sum_x_lo
            slope_lo_5pt     := denom_lo != 0.0 ? (nf_lo * sum_xy_lo - sum_x_lo * sum_y_lo) / denom_lo : 0.0
            intercept_lo_5pt := nf_lo  != 0.0 ? (sum_y_lo - slope_lo_5pt * sum_x_lo) / nf_lo : na

    [slope_hi_5pt, intercept_hi_5pt, slope_lo_5pt, intercept_lo_5pt]

//──────── Lines IDs for Method 2
var line hi_line_5pt = na
var line lo_line_5pt = na

//══════════════
// 5-Point Straight Channel Logic (Method 2)
//══════════════
if enable_five_point_channel
    [slope_hi_5pt, intercept_hi_5pt, slope_lo_5pt, intercept_lo_5pt] = calcFivePointChannel(len_channel_5pt)

    bool can_draw_hi_5pt = not na(slope_hi_5pt) and not na(intercept_hi_5pt)
    bool can_draw_lo_5pt = not na(slope_lo_5pt) and not na(intercept_lo_5pt)

    int   x1_5pt  = bar_index - len_channel_5pt + 1
    int   x2_5pt  = bar_index
    float x1f_5pt = x1_5pt
    float x2f_5pt = x2_5pt

    // Upper line
    if can_draw_hi_5pt
        float y1_hi_5pt = slope_hi_5pt * x1f_5pt + intercept_hi_5pt
        float y2_hi_5pt = slope_hi_5pt * x2f_5pt + intercept_hi_5pt
        if na(hi_line_5pt)
            hi_line_5pt := line.new(
                 x1_5pt, y1_hi_5pt,
                 x2_5pt, y2_hi_5pt,
                 xloc   = xloc.bar_index,
                 extend = extend.none,
                 color  = five_hi_color,
                 style  = get_line_style(five_line_style),
                 width  = five_line_width)
        else
            line.set_xy1(hi_line_5pt, x1_5pt, y1_hi_5pt)
            line.set_xy2(hi_line_5pt, x2_5pt, y2_hi_5pt)
            line.set_color(hi_line_5pt, five_hi_color)
            line.set_style(hi_line_5pt, get_line_style(five_line_style))
            line.set_width(hi_line_5pt, five_line_width)
    else
        if not na(hi_line_5pt)
            line.delete(hi_line_5pt)
            hi_line_5pt := na

    // Lower line
    if can_draw_lo_5pt
        float y1_lo_5pt = slope_lo_5pt * x1f_5pt + intercept_lo_5pt
        float y2_lo_5pt = slope_lo_5pt * x2f_5pt + intercept_lo_5pt
        if na(lo_line_5pt)
            lo_line_5pt := line.new(
                 x1_5pt, y1_lo_5pt,
                 x2_5pt, y2_lo_5pt,
                 xloc   = xloc.bar_index,
                 extend = extend.none,
                 color  = five_lo_color,
                 style  = get_line_style(five_line_style),
                 width  = five_line_width)
        else
            line.set_xy1(lo_line_5pt, x1_5pt, y1_lo_5pt)
            line.set_xy2(lo_line_5pt, x2_5pt, y2_lo_5pt)
            line.set_color(lo_line_5pt, five_lo_color)
            line.set_style(lo_line_5pt, get_line_style(five_line_style))
            line.set_width(lo_line_5pt, five_line_width)
    else
        if not na(lo_line_5pt)
            line.delete(lo_line_5pt)
            lo_line_5pt := na
else
    // Disable: clean up Method 2 lines
    if not na(hi_line_5pt)
        line.delete(hi_line_5pt)
        hi_line_5pt := na
    if not na(lo_line_5pt)
        line.delete(lo_line_5pt)
        lo_line_5pt := na

//══════════════════════════════════════════════════════════════════════════════════
// ─── DASHBOARD — Channel Analytics Panel
//══════════════════════════════════════════════════════════════════════════════════

//──────────────────────────────────────────────
// Dashboard Inputs
//──────────────────────────────────────────────
string grpDash = "Dashboard"

bool dash_enabled = input.bool(
     defval  = true,
     title   = "Enable Dashboard",
     tooltip = "Toggle the channel analytics dashboard on or off.\nDisplays period, prices, direction, and breakout status for each channel.",
     group   = grpDash)

string dash_lang = input.string(
     defval  = "English",
     options = ["English", "Türkçe", "العربية", "Русский", "Deutsch", "Français", "Español", "Português", "Svenska", "Norsk", "Dansk", "עברית", "فارسی"],
     title   = "Dashboard Language",
     tooltip = "Select the display language for all dashboard labels.\nRTL alignment is automatically applied for Arabic, Hebrew, and Persian.",
     group   = grpDash)

// Font size — no artificial upper limit; TradingView's own constraints apply
int dash_font = input.int(
     defval  = 8,
     minval  = 1,
     title   = "Font Size",
     tooltip = "Numeric font size (pt) for all dashboard text. No upper cap — TradingView's own rendering limits apply.",
     group   = grpDash)

string dash_pos = input.string(
     defval  = "Bottom Right",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"],
     title   = "Dashboard Position",
     tooltip = "Position of the dashboard on the chart.",
     group   = grpDash)

float dash_threshold = input.float(
     defval  = 0.5,
     minval  = 0.1,
     maxval  = 5.0,
     step    = 0.1,
     title   = "Direction Threshold (%)",
     tooltip = "Midline percentage change threshold for channel direction classification.\n" +
               "If midline % change > +threshold → Bullish.\n" +
               "If midline % change < −threshold → Bearish.\n" +
               "Otherwise → Range.\n" +
               "Default 0.5% is derived from standard technical analysis channel classification (Bulkowski, Murphy).",
     group   = grpDash)

//──────────────────────────────────────────────
// Dashboard — Position Resolver
//──────────────────────────────────────────────
getDashPos(string pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

//──────────────────────────────────────────────
// Dashboard — Translation Engine (array-indexed, 13 languages)
//──────────────────────────────────────────────
// Language index mapping:
// 0=English, 1=Türkçe, 2=العربية, 3=Русский, 4=Deutsch,
// 5=Français, 6=Español, 7=Português, 8=Svenska, 9=Norsk,
// 10=Dansk, 11=עברית, 12=فارسی

int _li = switch dash_lang
    "Türkçe"   => 1
    "العربية"  => 2
    "Русский"  => 3
    "Deutsch"  => 4
    "Français" => 5
    "Español"  => 6
    "Português"=> 7
    "Svenska"  => 8
    "Norsk"    => 9
    "Dansk"    => 10
    "עברית"    => 11
    "فارسی"    => 12
    =>            0

// RTL flag: Arabic (2), Hebrew (11), Persian (12)
bool _rtl = (_li == 2 or _li == 11 or _li == 12)

// ─── Label Translation Arrays — each holds 13 entries in language-index order ───
//                                  EN                TR                  AR                  RU                  DE                  FR                  ES                    PT                    SV                  NO                  DA                  HE                    FA
var string[] _t_m1     = array.from("Pivot Span",     "Pivot Aralığı",    "نطاق المحور",      "Пивот-Спан",       "Pivot-Spanne",     "Pivot Span",       "Pivote Span",        "Pivot Span",         "Pivotstrecka",     "Pivotspenn",       "Pivotspænd",       "טווח ציר",           "محدوده پیوت")
var string[] _t_m2     = array.from("5-Pt Channel",   "5-Nokta Kanalı",   "قناة 5 نقاط",      "5-Точечный",       "5-Pkt-Kanal",      "Canal 5-Pts",      "Canal 5-Pts",        "Canal 5-Pts",        "5-Pkt Kanal",      "5-Pkt Kanal",      "5-Pkt Kanal",      "ערוץ 5 נקודות",      "کانال ۵ نقطه")
var string[] _t_metric = array.from("Metric",         "Metrik",           "المقياس",          "Метрика",          "Kennzahl",         "Mesure",           "Métrica",            "Métrica",            "Mätvärde",         "Måltall",          "Målepunkt",        "מדד",                "شاخص")
var string[] _t_period = array.from("Period",         "Dönem",            "الفترة",           "Период",           "Zeitraum",         "Période",          "Período",            "Período",            "Period",           "Periode",          "Periode",          "תקופה",              "دوره")
var string[] _t_up_s   = array.from("Upper Start",    "Üst Başlangıç",    "بداية علوية",      "Верх начало",      "Oben Start",       "Haut début",       "Superior inicio",    "Superior início",    "Övre start",       "Øvre start",       "Øvre start",       "עליון התחלה",         "بالا شروع")
var string[] _t_up_e   = array.from("Upper End",      "Üst Bitiş",        "نهاية علوية",      "Верх конец",       "Oben Ende",        "Haut fin",         "Superior fin",       "Superior fim",       "Övre slut",        "Øvre slutt",       "Øvre slut",        "עליון סוף",           "بالا پایان")
var string[] _t_lo_s   = array.from("Lower Start",    "Alt Başlangıç",    "بداية سفلية",      "Низ начало",       "Unten Start",      "Bas début",        "Inferior inicio",    "Inferior início",    "Nedre start",      "Nedre start",      "Nedre start",      "תחתון התחלה",         "پایین شروع")
var string[] _t_lo_e   = array.from("Lower End",      "Alt Bitiş",        "نهاية سفلية",      "Низ конец",        "Unten Ende",       "Bas fin",          "Inferior fin",       "Inferior fim",       "Nedre slut",       "Nedre slutt",      "Nedre slut",       "תחתון סוף",           "پایین پایان")
var string[] _t_dir    = array.from("Direction",      "Yön",              "الاتجاه",          "Направление",      "Richtung",         "Direction",        "Dirección",          "Direção",            "Riktning",         "Retning",          "Retning",          "כיוון",               "جهت")
var string[] _t_brk    = array.from("Breakout",       "Kırılım",          "الاختراق",         "Пробой",           "Ausbruch",         "Cassure",          "Ruptura",            "Rompimento",         "Utbrott",          "Utbrudd",          "Udbrud",           "פריצה",               "شکست")
var string[] _t_bull   = array.from("Bullish ▲",      "Yükseliş ▲",       "صاعد ▲",           "Рост ▲",           "Aufwärts ▲",       "Haussier ▲",       "Alcista ▲",          "Alta ▲",             "Uppåt ▲",          "Oppgang ▲",        "Opadgående ▲",     "עולה ▲",              "صعودی ▲")
var string[] _t_bear   = array.from("Bearish ▼",      "Düşüş ▼",          "هابط ▼",           "Падение ▼",        "Abwärts ▼",        "Baissier ▼",       "Bajista ▼",          "Baixa ▼",            "Nedåt ▼",          "Nedgang ▼",        "Nedadgående ▼",    "יורד ▼",              "نزولی ▼")
var string[] _t_rng    = array.from("Range ↔",        "Yatay ↔",          "عرضي ↔",           "Боковик ↔",        "Seitwärts ↔",      "Neutre ↔",         "Lateral ↔",          "Lateral ↔",          "Sidled ↔",         "Sidelengs ↔",      "Sidelæns ↔",       "צידי ↔",              "رنج ↔")
var string[] _t_above  = array.from("Above ⬆",        "Üstünde ⬆",        "فوق ⬆",            "Выше ⬆",           "Darüber ⬆",        "Au-dessus ⬆",      "Arriba ⬆",           "Acima ⬆",            "Ovanför ⬆",        "Over ⬆",           "Over ⬆",           "מעל ⬆",               "بالاتر ⬆")
var string[] _t_below  = array.from("Below ⬇",        "Altında ⬇",        "تحت ⬇",            "Ниже ⬇",           "Darunter ⬇",       "En-dessous ⬇",     "Abajo ⬇",            "Abaixo ⬇",           "Nedanför ⬇",       "Under ⬇",          "Under ⬇",          "מתחת ⬇",              "پایین‌تر ⬇")
var string[] _t_inside = array.from("Inside ◈",       "İçinde ◈",         "داخل ◈",           "Внутри ◈",         "Innerhalb ◈",      "Intérieur ◈",      "Dentro ◈",           "Dentro ◈",           "Innanför ◈",       "Innenfor ◈",       "Indeni ◈",         "בתוך ◈",              "داخل ◈")
var string[] _t_na     = array.from("N/A",            "Yok",              "غ/م",              "Н/Д",              "K/A",              "N/D",              "N/D",                "N/D",                "N/T",              "I/T",              "I/T",              "אין",                 "ندارد")

// ─── Tooltip Translation Arrays — each holds 13 entries in language-index order ───
// Row 0 (Headers)
var string[] _tt_hdr_metric = array.from(
     "Row labels for channel analytics data",
     "Kanal analitiği satır etiketleri",
     "تسميات صفوف بيانات تحليل القناة",
     "Метки строк аналитики канала",
     "Zeilenbeschriftungen der Kanalanalysedaten",
     "Libellés des lignes de données d'analyse du canal",
     "Etiquetas de fila de datos analíticos del canal",
     "Rótulos das linhas de dados analíticos do canal",
     "Radetiketter för kanalanalysdata",
     "Radetiketter for kanalanalysedata",
     "Rækkeetiketter for kanalanalysedata",
     "תוויות שורות לנתוני ניתוח ערוץ",
     "برچسب ردیف‌های داده تحلیل کانال")

var string[] _tt_hdr_m1 = array.from(
     "Pivot Span Trendline: linear interpolation between first and last detected pivot highs/lows",
     "Pivot Aralığı Trend Çizgisi: tespit edilen ilk ve son pivot yüksek/düşük arasında doğrusal interpolasyon",
     "خط اتجاه نطاق المحور: استيفاء خطي بين أول وآخر قمم/قيعان محورية مكتشفة",
     "Линия тренда Пивот-Спан: линейная интерполяция между первым и последним обнаруженными пивотами",
     "Pivot-Spanne Trendlinie: lineare Interpolation zwischen erstem und letztem erkannten Pivot-Hoch/-Tief",
     "Ligne de tendance Pivot Span: interpolation linéaire entre les premiers et derniers pivots hauts/bas détectés",
     "Línea de tendencia Pivote Span: interpolación lineal entre los primeros y últimos pivotes altos/bajos detectados",
     "Linha de tendência Pivot Span: interpolação linear entre os primeiros e últimos pivots altos/baixos detectados",
     "Pivotstrecka trendlinje: linjär interpolation mellan första och sista detekterade pivothöjder/-låga",
     "Pivotspenn trendlinje: lineær interpolasjon mellom første og siste oppdagede pivothøyder/-lavpunkter",
     "Pivotspænd trendlinje: lineær interpolation mellem første og sidste detekterede pivothøjder/-lavpunkter",
     "קו מגמה טווח ציר: אינטרפולציה ליניארית בין ראשון לאחרון של שיאים/שפלים ציריים שזוהו",
     "خط روند محدوده پیوت: درون‌یابی خطی بین اولین و آخرین پیوت‌های سقف/کف شناسایی‌شده")

var string[] _tt_hdr_m2 = array.from(
     "5-Point Straight Channel: OLS regression fitted to 5 segment extremes within the lookback window",
     "5-Nokta Düz Kanal: geri bakış penceresindeki 5 segment ucuna OLS regresyonu uydurulmuş",
     "قناة 5 نقاط مستقيمة: انحدار OLS مُطبَّق على 5 نقاط قصوى ضمن نافذة المراجعة",
     "5-Точечный канал: OLS-регрессия по 5 экстремумам сегментов в окне наблюдения",
     "5-Punkt-Kanal: OLS-Regression an 5 Segment-Extremwerte im Rückblickfenster angepasst",
     "Canal 5-Pts: régression OLS ajustée sur les 5 extrêmes de segments dans la fenêtre de rétrospection",
     "Canal 5-Pts: regresión OLS ajustada a 5 extremos de segmentos dentro de la ventana de retrospección",
     "Canal 5-Pts: regressão OLS ajustada a 5 extremos de segmentos na janela de retrospectiva",
     "5-Pkt Kanal: OLS-regression anpassad till 5 segmentextremer inom tillbakablicksfönstret",
     "5-Pkt Kanal: OLS-regresjon tilpasset 5 segmentekstremer i tilbakeblikksvinduet",
     "5-Pkt Kanal: OLS-regression tilpasset 5 segmentekstremer i tilbagebliksvinduet",
     "ערוץ 5 נקודות ישר: רגרסיית OLS מותאמת ל-5 קיצוני מקטעים בחלון התצפית",
     "کانال مستقیم ۵ نقطه: رگرسیون OLS بر ۵ اکسترمم بخش در پنجره بازنگری")

// Row 1 (Period)
var string[] _tt_period_lbl = array.from(
     "Calendar date range covered by the channel (start → current bar)",
     "Kanalın kapsadığı takvim tarih aralığı (başlangıç → mevcut çubuk)",
     "النطاق الزمني الذي تغطيه القناة (البداية → الشمعة الحالية)",
     "Календарный диапазон дат канала (начало → текущий бар)",
     "Kalenderdatumsbereich des Kanals (Start → aktueller Balken)",
     "Plage de dates calendaires couverte par le canal (début → barre actuelle)",
     "Rango de fechas del canal (inicio → barra actual)",
     "Intervalo de datas do canal (início → barra atual)",
     "Kalenderdatumintervall som kanalen täcker (start → aktuell stapel)",
     "Kalenderdatointervall dekket av kanalen (start → gjeldende stolpe)",
     "Kalenderdatointervallet dækket af kanalen (start → aktuel bjælke)",
     "טווח תאריכים של הערוץ (התחלה → עמוד נוכחי)",
     "بازه تاریخی پوشش‌داده‌شده توسط کانال (شروع → کندل فعلی)")

var string[] _tt_period_m1 = array.from(
     "Start and end dates of the Pivot Span channel based on the lookback length",
     "Geri bakış uzunluğuna göre Pivot Aralığı kanalının başlangıç ve bitiş tarihleri",
     "تواريخ بداية ونهاية قناة نطاق المحور بناءً على طول المراجعة",
     "Даты начала и конца канала Пивот-Спан на основе длины наблюдения",
     "Start- und Enddaten des Pivot-Spanne-Kanals basierend auf der Rückblicklänge",
     "Dates de début et de fin du canal Pivot Span selon la longueur de rétrospection",
     "Fechas de inicio y fin del canal Pivote Span según la longitud de retrospección",
     "Datas de início e fim do canal Pivot Span com base no comprimento de retrospectiva",
     "Start- och slutdatum för Pivotstrecka-kanalen baserat på tillbakablickslängden",
     "Start- og sluttdatoer for Pivotspenn-kanalen basert på tilbakeblikklengden",
     "Start- og slutdatoer for Pivotspænd-kanalen baseret på tilbagebliklængden",
     "תאריכי התחלה וסוף של ערוץ טווח ציר לפי אורך חלון התצפית",
     "تاریخ شروع و پایان کانال محدوده پیوت بر اساس طول بازنگری")

var string[] _tt_period_m2 = array.from(
     "Start and end dates of the 5-Point channel based on the channel length",
     "Kanal uzunluğuna göre 5-Nokta kanalının başlangıç ve bitiş tarihleri",
     "تواريخ بداية ونهاية قناة 5 نقاط بناءً على طول القناة",
     "Даты начала и конца 5-Точечного канала на основе длины канала",
     "Start- und Enddaten des 5-Punkt-Kanals basierend auf der Kanallänge",
     "Dates de début et de fin du canal 5-Pts selon la longueur du canal",
     "Fechas de inicio y fin del canal 5-Pts según la longitud del canal",
     "Datas de início e fim do canal 5-Pts com base no comprimento do canal",
     "Start- och slutdatum för 5-Pkt-kanalen baserat på kanallängden",
     "Start- og sluttdatoer for 5-Pkt-kanalen basert på kanallengden",
     "Start- og slutdatoer for 5-Pkt-kanalen baseret på kanallængden",
     "תאריכי התחלה וסוף של ערוץ 5 נקודות לפי אורך הערוץ",
     "تاریخ شروع و پایان کانال ۵ نقطه بر اساس طول کانال")

// Row 2 (Upper Start)
var string[] _tt_ups_lbl = array.from(
     "Price level of the upper (high) trend line at the channel starting bar",
     "Kanal başlangıç çubuğunda üst (yüksek) trend çizgisinin fiyat seviyesi",
     "مستوى سعر خط الاتجاه العلوي عند شمعة بداية القناة",
     "Уровень цены верхней (high) линии тренда на начальном баре канала",
     "Preisniveau der oberen (High-)Trendlinie am Kanal-Startbalken",
     "Niveau de prix de la ligne de tendance supérieure au début du canal",
     "Nivel de precio de la línea de tendencia superior al inicio del canal",
     "Nível de preço da linha de tendência superior na barra inicial do canal",
     "Prisnivå för den övre (hög) trendlinjen vid kanalens startstapel",
     "Prisnivå for den øvre (høy) trendlinjen ved kanalens startstolpe",
     "Prisniveau for den øvre (høj) trendlinje ved kanalens startbjælke",
     "רמת מחיר של קו המגמה העליון בעמוד ההתחלה של הערוץ",
     "سطح قیمت خط روند بالایی در کندل شروع کانال")

var string[] _tt_ups_m1 = array.from(
     "Pivot Span upper line price at channel start",
     "Pivot Aralığı üst çizgi fiyatı — kanal başlangıcı",
     "سعر الخط العلوي لنطاق المحور عند بداية القناة",
     "Цена верхней линии Пивот-Спан в начале канала",
     "Pivot-Spanne obere Linie Preis am Kanalstart",
     "Prix de la ligne supérieure Pivot Span au début du canal",
     "Precio línea superior Pivote Span al inicio del canal",
     "Preço linha superior Pivot Span no início do canal",
     "Pivotstrecka övre linje pris vid kanalstart",
     "Pivotspenn øvre linje pris ved kanalstart",
     "Pivotspænd øvre linje pris ved kanalstart",
     "מחיר קו עליון טווח ציר בתחילת הערוץ",
     "قیمت خط بالایی محدوده پیوت در شروع کانال")

var string[] _tt_ups_m2 = array.from(
     "5-Point channel upper line price at channel start",
     "5-Nokta kanalı üst çizgi fiyatı — kanal başlangıcı",
     "سعر الخط العلوي لقناة 5 نقاط عند بداية القناة",
     "Цена верхней линии 5-Точечного канала в начале канала",
     "5-Punkt-Kanal obere Linie Preis am Kanalstart",
     "Prix de la ligne supérieure canal 5-Pts au début du canal",
     "Precio línea superior canal 5-Pts al inicio del canal",
     "Preço linha superior canal 5-Pts no início do canal",
     "5-Pkt kanal övre linje pris vid kanalstart",
     "5-Pkt kanal øvre linje pris ved kanalstart",
     "5-Pkt kanal øvre linje pris ved kanalstart",
     "מחיר קו עליון ערוץ 5 נקודות בתחילת הערוץ",
     "قیمت خط بالایی کانال ۵ نقطه در شروع کانال")

// Row 3 (Upper End)
var string[] _tt_upe_lbl = array.from(
     "Price level of the upper (high) trend line at the current bar",
     "Mevcut çubukta üst (yüksek) trend çizgisinin fiyat seviyesi",
     "مستوى سعر خط الاتجاه العلوي عند الشمعة الحالية",
     "Уровень цены верхней (high) линии тренда на текущем баре",
     "Preisniveau der oberen (High-)Trendlinie am aktuellen Balken",
     "Niveau de prix de la ligne de tendance supérieure à la barre actuelle",
     "Nivel de precio de la línea de tendencia superior en la barra actual",
     "Nível de preço da linha de tendência superior na barra atual",
     "Prisnivå för den övre (hög) trendlinjen vid aktuell stapel",
     "Prisnivå for den øvre (høy) trendlinjen ved gjeldende stolpe",
     "Prisniveau for den øvre (høj) trendlinje ved aktuel bjælke",
     "רמת מחיר של קו המגמה העליון בעמוד הנוכחי",
     "سطح قیمت خط روند بالایی در کندل فعلی")

var string[] _tt_upe_m1 = array.from(
     "Pivot Span upper line price at current bar",
     "Pivot Aralığı üst çizgi fiyatı — mevcut çubuk",
     "سعر الخط العلوي لنطاق المحور عند الشمعة الحالية",
     "Цена верхней линии Пивот-Спан на текущем баре",
     "Pivot-Spanne obere Linie Preis am aktuellen Balken",
     "Prix de la ligne supérieure Pivot Span à la barre actuelle",
     "Precio línea superior Pivote Span en la barra actual",
     "Preço linha superior Pivot Span na barra atual",
     "Pivotstrecka övre linje pris vid aktuell stapel",
     "Pivotspenn øvre linje pris ved gjeldende stolpe",
     "Pivotspænd øvre linje pris ved aktuel bjælke",
     "מחיר קו עליון טווח ציר בעמוד הנוכחי",
     "قیمت خط بالایی محدوده پیوت در کندل فعلی")

var string[] _tt_upe_m2 = array.from(
     "5-Point channel upper line price at current bar",
     "5-Nokta kanalı üst çizgi fiyatı — mevcut çubuk",
     "سعر الخط العلوي لقناة 5 نقاط عند الشمعة الحالية",
     "Цена верхней линии 5-Точечного канала на текущем баре",
     "5-Punkt-Kanal obere Linie Preis am aktuellen Balken",
     "Prix de la ligne supérieure canal 5-Pts à la barre actuelle",
     "Precio línea superior canal 5-Pts en la barra actual",
     "Preço linha superior canal 5-Pts na barra atual",
     "5-Pkt kanal övre linje pris vid aktuell stapel",
     "5-Pkt kanal øvre linje pris ved gjeldende stolpe",
     "5-Pkt kanal øvre linje pris ved aktuel bjælke",
     "מחיר קו עליון ערוץ 5 נקודות בעמוד הנוכחי",
     "قیمت خط بالایی کانال ۵ نقطه در کندل فعلی")

// Row 4 (Lower Start)
var string[] _tt_los_lbl = array.from(
     "Price level of the lower (low) trend line at the channel starting bar",
     "Kanal başlangıç çubuğunda alt (düşük) trend çizgisinin fiyat seviyesi",
     "مستوى سعر خط الاتجاه السفلي عند شمعة بداية القناة",
     "Уровень цены нижней (low) линии тренда на начальном баре канала",
     "Preisniveau der unteren (Low-)Trendlinie am Kanal-Startbalken",
     "Niveau de prix de la ligne de tendance inférieure au début du canal",
     "Nivel de precio de la línea de tendencia inferior al inicio del canal",
     "Nível de preço da linha de tendência inferior na barra inicial do canal",
     "Prisnivå för den nedre (låg) trendlinjen vid kanalens startstapel",
     "Prisnivå for den nedre (lav) trendlinjen ved kanalens startstolpe",
     "Prisniveau for den nedre (lav) trendlinje ved kanalens startbjælke",
     "רמת מחיר של קו המגמה התחתון בעמוד ההתחלה של הערוץ",
     "سطح قیمت خط روند پایینی در کندل شروع کانال")

var string[] _tt_los_m1 = array.from(
     "Pivot Span lower line price at channel start",
     "Pivot Aralığı alt çizgi fiyatı — kanal başlangıcı",
     "سعر الخط السفلي لنطاق المحور عند بداية القناة",
     "Цена нижней линии Пивот-Спан в начале канала",
     "Pivot-Spanne untere Linie Preis am Kanalstart",
     "Prix de la ligne inférieure Pivot Span au début du canal",
     "Precio línea inferior Pivote Span al inicio del canal",
     "Preço linha inferior Pivot Span no início do canal",
     "Pivotstrecka nedre linje pris vid kanalstart",
     "Pivotspenn nedre linje pris ved kanalstart",
     "Pivotspænd nedre linje pris ved kanalstart",
     "מחיר קו תחתון טווח ציר בתחילת הערוץ",
     "قیمت خط پایینی محدوده پیوت در شروع کانال")

var string[] _tt_los_m2 = array.from(
     "5-Point channel lower line price at channel start",
     "5-Nokta kanalı alt çizgi fiyatı — kanal başlangıcı",
     "سعر الخط السفلي لقناة 5 نقاط عند بداية القناة",
     "Цена нижней линии 5-Точечного канала в начале канала",
     "5-Punkt-Kanal untere Linie Preis am Kanalstart",
     "Prix de la ligne inférieure canal 5-Pts au début du canal",
     "Precio línea inferior canal 5-Pts al inicio del canal",
     "Preço linha inferior canal 5-Pts no início do canal",
     "5-Pkt kanal nedre linje pris vid kanalstart",
     "5-Pkt kanal nedre linje pris ved kanalstart",
     "5-Pkt kanal nedre linje pris ved kanalstart",
     "מחיר קו תחתון ערוץ 5 נקודות בתחילת הערוץ",
     "قیمت خط پایینی کانال ۵ نقطه در شروع کانال")

// Row 5 (Lower End)
var string[] _tt_loe_lbl = array.from(
     "Price level of the lower (low) trend line at the current bar",
     "Mevcut çubukta alt (düşük) trend çizgisinin fiyat seviyesi",
     "مستوى سعر خط الاتجاه السفلي عند الشمعة الحالية",
     "Уровень цены нижней (low) линии тренда на текущем баре",
     "Preisniveau der unteren (Low-)Trendlinie am aktuellen Balken",
     "Niveau de prix de la ligne de tendance inférieure à la barre actuelle",
     "Nivel de precio de la línea de tendencia inferior en la barra actual",
     "Nível de preço da linha de tendência inferior na barra atual",
     "Prisnivå för den nedre (låg) trendlinjen vid aktuell stapel",
     "Prisnivå for den nedre (lav) trendlinjen ved gjeldende stolpe",
     "Prisniveau for den nedre (lav) trendlinje ved aktuel bjælke",
     "רמת מחיר של קו המגמה התחתון בעמוד הנוכחי",
     "سطح قیمت خط روند پایینی در کندل فعلی")

var string[] _tt_loe_m1 = array.from(
     "Pivot Span lower line price at current bar",
     "Pivot Aralığı alt çizgi fiyatı — mevcut çubuk",
     "سعر الخط السفلي لنطاق المحور عند الشمعة الحالية",
     "Цена нижней линии Пивот-Спан на текущем баре",
     "Pivot-Spanne untere Linie Preis am aktuellen Balken",
     "Prix de la ligne inférieure Pivot Span à la barre actuelle",
     "Precio línea inferior Pivote Span en la barra actual",
     "Preço linha inferior Pivot Span na barra atual",
     "Pivotstrecka nedre linje pris vid aktuell stapel",
     "Pivotspenn nedre linje pris ved gjeldende stolpe",
     "Pivotspænd nedre linje pris ved aktuel bjælke",
     "מחיר קו תחתון טווח ציר בעמוד הנוכחי",
     "قیمت خط پایینی محدوده پیوت در کندل فعلی")

var string[] _tt_loe_m2 = array.from(
     "5-Point channel lower line price at current bar",
     "5-Nokta kanalı alt çizgi fiyatı — mevcut çubuk",
     "سعر الخط السفلي لقناة 5 نقاط عند الشمعة الحالية",
     "Цена нижней линии 5-Точечного канала на текущем баре",
     "5-Punkt-Kanal untere Linie Preis am aktuellen Balken",
     "Prix de la ligne inférieure canal 5-Pts à la barre actuelle",
     "Precio línea inferior canal 5-Pts en la barra actual",
     "Preço linha inferior canal 5-Pts na barra atual",
     "5-Pkt kanal nedre linje pris vid aktuell stapel",
     "5-Pkt kanal nedre linje pris ved gjeldende stolpe",
     "5-Pkt kanal nedre linje pris ved aktuel bjælke",
     "מחיר קו תחתון ערוץ 5 נקודות בעמוד הנוכחי",
     "قیمت خط پایینی کانال ۵ نقطه در کندل فعلی")

// Row 6 (Direction)
var string[] _tt_dir_lbl = array.from(
     "Channel direction via midline slope % change.\nMidline = (upper + lower) / 2.\nCompared against the configured threshold (default ±0.5%).",
     "Orta çizgi eğimi % değişimine göre kanal yönü.\nOrta çizgi = (üst + alt) / 2.\nYapılandırılmış eşikle karşılaştırılır (varsayılan ±%0,5).",
     "اتجاه القناة عبر تغيير % ميل خط الوسط.\nخط الوسط = (علوي + سفلي) / 2.\nمقارنة بالحد المُعَدّ (افتراضي ±0.5%).",
     "Направление канала по % изменению наклона средней линии.\nСредняя = (верх + низ) / 2.\nСравнивается с порогом (по умолч. ±0,5%).",
     "Kanalrichtung über Mittellinie-Steigung in %.\nMittellinie = (oben + unten) / 2.\nVerglichen mit dem Schwellenwert (Standard ±0,5%).",
     "Direction du canal via variation % de la pente médiane.\nMédiane = (haut + bas) / 2.\nComparée au seuil configuré (défaut ±0,5%).",
     "Dirección del canal por cambio % de pendiente de línea media.\nLínea media = (superior + inferior) / 2.\nComparada con el umbral configurado (predeterminado ±0,5%).",
     "Direção do canal via variação % da inclinação da linha média.\nLinha média = (superior + inferior) / 2.\nComparada com o limiar configurado (padrão ±0,5%).",
     "Kanalriktning via mittlinjens lutning i %.\nMittlinje = (övre + nedre) / 2.\nJämfört med tröskelvärdet (standard ±0,5%).",
     "Kanalretning via midtlinjens helning i %.\nMidtlinje = (øvre + nedre) / 2.\nSammenlignet med terskelen (standard ±0,5%).",
     "Kanalretning via midtlinjens hældning i %.\nMidtlinje = (øvre + nedre) / 2.\nSammenlignet med tærsklen (standard ±0,5%).",
     "כיוון ערוץ לפי % שינוי שיפוע קו האמצע.\nקו אמצע = (עליון + תחתון) / 2.\nמושווה לסף המוגדר (ברירת מחדל ±0.5%).",
     "جهت کانال از طریق تغییر % شیب خط میانی.\nخط میانی = (بالا + پایین) / 2.\nمقایسه با آستانه تنظیم‌شده (پیش‌فرض ±0.5%).")

var string[] _tt_dir_m1 = array.from(
     "Pivot Span direction: Bullish if midline rises > threshold, Bearish if falls, Range otherwise",
     "Pivot Aralığı yönü: Orta çizgi eşikten fazla yükselirse Yükseliş, düşerse Düşüş, aksi halde Yatay",
     "اتجاه نطاق المحور: صاعد إذا ارتفع خط الوسط > الحد، هابط إذا انخفض، عرضي خلاف ذلك",
     "Направление Пивот-Спан: Рост если средняя > порога, Падение если ниже, Боковик иначе",
     "Pivot-Spanne Richtung: Aufwärts wenn Mittellinie > Schwelle steigt, Abwärts wenn fällt, Seitwärts sonst",
     "Direction Pivot Span: Haussier si médiane > seuil, Baissier si baisse, Neutre sinon",
     "Dirección Pivote Span: Alcista si línea media > umbral, Bajista si cae, Lateral en otro caso",
     "Direção Pivot Span: Alta se linha média > limiar, Baixa se cai, Lateral caso contrário",
     "Pivotstrecka riktning: Uppåt om mittlinje > tröskel, Nedåt om faller, Sidled annars",
     "Pivotspenn retning: Oppgang om midtlinje > terskel, Nedgang om faller, Sidelengs ellers",
     "Pivotspænd retning: Opadgående om midtlinje > tærskel, Nedadgående om falder, Sidelæns ellers",
     "כיוון טווח ציר: עולה אם קו אמצע > סף, יורד אם נופל, צידי אחרת",
     "جهت محدوده پیوت: صعودی اگر خط میانی > آستانه، نزولی اگر افت، رنج در غیر این صورت")

var string[] _tt_dir_m2 = array.from(
     "5-Point channel direction: Bullish if midline rises > threshold, Bearish if falls, Range otherwise",
     "5-Nokta kanalı yönü: Orta çizgi eşikten fazla yükselirse Yükseliş, düşerse Düşüş, aksi halde Yatay",
     "اتجاه قناة 5 نقاط: صاعد إذا ارتفع خط الوسط > الحد، هابط إذا انخفض، عرضي خلاف ذلك",
     "Направление 5-Точечного: Рост если средняя > порога, Падение если ниже, Боковик иначе",
     "5-Punkt-Kanal Richtung: Aufwärts wenn Mittellinie > Schwelle steigt, Abwärts wenn fällt, Seitwärts sonst",
     "Direction canal 5-Pts: Haussier si médiane > seuil, Baissier si baisse, Neutre sinon",
     "Dirección canal 5-Pts: Alcista si línea media > umbral, Bajista si cae, Lateral en otro caso",
     "Direção canal 5-Pts: Alta se linha média > limiar, Baixa se cai, Lateral caso contrário",
     "5-Pkt kanal riktning: Uppåt om mittlinje > tröskel, Nedåt om faller, Sidled annars",
     "5-Pkt kanal retning: Oppgang om midtlinje > terskel, Nedgang om faller, Sidelengs ellers",
     "5-Pkt kanal retning: Opadgående om midtlinje > tærskel, Nedadgående om falder, Sidelæns ellers",
     "כיוון ערוץ 5 נקודות: עולה אם קו אמצע > סף, יורד אם נופל, צידי אחרת",
     "جهت کانال ۵ نقطه: صعودی اگر خط میانی > آستانه، نزولی اگر افت، رنج در غیر این صورت")

// Row 7 (Breakout)
var string[] _tt_brk_lbl = array.from(
     "Whether the current close has broken above the upper line, below the lower line, or remains inside the channel",
     "Mevcut kapanışın üst çizgiyi aşıp aşmadığı, alt çizginin altına düşüp düşmediği veya kanal içinde kalıp kalmadığı",
     "ما إذا كان الإغلاق الحالي قد اخترق فوق الخط العلوي أو تحت السفلي أو بقي داخل القناة",
     "Пробил ли текущий close верхнюю линию, нижнюю, или остаётся внутри канала",
     "Ob der aktuelle Schlusskurs über die obere Linie, unter die untere ausgebrochen ist oder innerhalb bleibt",
     "Si le close actuel a cassé au-dessus de la ligne supérieure, en dessous de l'inférieure, ou reste dans le canal",
     "Si el cierre actual ha roto por encima de la línea superior, por debajo de la inferior, o permanece dentro del canal",
     "Se o fechamento atual rompeu acima da linha superior, abaixo da inferior, ou permanece dentro do canal",
     "Om den aktuella stängningen har brutit ovanför den övre linjen, under den nedre, eller finns kvar inuti kanalen",
     "Om gjeldende sluttkurs har brutt over den øvre linjen, under den nedre, eller er innenfor kanalen",
     "Om den aktuelle lukning har brudt over den øvre linje, under den nedre, eller forbliver inde i kanalen",
     "האם הסגירה הנוכחית פרצה מעל הקו העליון, מתחת לתחתון, או נשארת בתוך הערוץ",
     "آیا بسته‌شدن فعلی بالاتر از خط بالا، پایین‌تر از خط پایین، یا داخل کانال مانده است")

var string[] _tt_brk_m1 = array.from(
     "Pivot Span breakout: Above = close > upper, Below = close < lower, Inside = within channel",
     "Pivot Aralığı kırılım: Üstünde = kapanış > üst, Altında = kapanış < alt, İçinde = kanal içi",
     "اختراق نطاق المحور: فوق = إغلاق > علوي، تحت = إغلاق < سفلي، داخل = ضمن القناة",
     "Пробой Пивот-Спан: Выше = close > верх, Ниже = close < низ, Внутри = в канале",
     "Pivot-Spanne Ausbruch: Darüber = Close > oben, Darunter = Close < unten, Innerhalb = im Kanal",
     "Cassure Pivot Span: Au-dessus = close > haut, En-dessous = close < bas, Intérieur = dans le canal",
     "Ruptura Pivote Span: Arriba = cierre > superior, Abajo = cierre < inferior, Dentro = en el canal",
     "Rompimento Pivot Span: Acima = close > superior, Abaixo = close < inferior, Dentro = no canal",
     "Pivotstrecka utbrott: Ovanför = stängning > övre, Nedanför = stängning < nedre, Innanför = i kanalen",
     "Pivotspenn utbrudd: Over = sluttkurs > øvre, Under = sluttkurs < nedre, Innenfor = i kanalen",
     "Pivotspænd udbrud: Over = lukning > øvre, Under = lukning < nedre, Indeni = i kanalen",
     "פריצת טווח ציר: מעל = סגירה > עליון, מתחת = סגירה < תחתון, בתוך = בתוך הערוץ",
     "شکست محدوده پیوت: بالاتر = بسته‌شدن > بالا، پایین‌تر = بسته‌شدن < پایین، داخل = درون کانال")

var string[] _tt_brk_m2 = array.from(
     "5-Point channel breakout: Above = close > upper, Below = close < lower, Inside = within channel",
     "5-Nokta kanalı kırılım: Üstünde = kapanış > üst, Altında = kapanış < alt, İçinde = kanal içi",
     "اختراق قناة 5 نقاط: فوق = إغلاق > علوي، تحت = إغلاق < سفلي، داخل = ضمن القناة",
     "Пробой 5-Точечного: Выше = close > верх, Ниже = close < низ, Внутри = в канале",
     "5-Punkt-Kanal Ausbruch: Darüber = Close > oben, Darunter = Close < unten, Innerhalb = im Kanal",
     "Cassure canal 5-Pts: Au-dessus = close > haut, En-dessous = close < bas, Intérieur = dans le canal",
     "Ruptura canal 5-Pts: Arriba = cierre > superior, Abajo = cierre < inferior, Dentro = en el canal",
     "Rompimento canal 5-Pts: Acima = close > superior, Abaixo = close < inferior, Dentro = no canal",
     "5-Pkt kanal utbrott: Ovanför = stängning > övre, Nedanför = stängning < nedre, Innanför = i kanalen",
     "5-Pkt kanal utbrudd: Over = sluttkurs > øvre, Under = sluttkurs < nedre, Innenfor = i kanalen",
     "5-Pkt kanal udbrud: Over = lukning > øvre, Under = lukning < nedre, Indeni = i kanalen",
     "פריצת ערוץ 5 נקודות: מעל = סגירה > עליון, מתחת = סגירה < תחתון, בתוך = בתוך הערוץ",
     "شکست کانال ۵ نقطه: بالاتر = بسته‌شدن > بالا، پایین‌تر = بسته‌شدن < پایین، داخل = درون کانال")

//──────────────────────────────────────────────
// Dashboard — Rendering (last bar only)
//──────────────────────────────────────────────
var table dash_table = na

if barstate.islast and dash_enabled
    // Delete previous table to avoid visual artifacts on real-time updates
    if not na(dash_table)
        table.delete(dash_table)

    // ─── Resolve translated labels ───
    string lm1     = array.get(_t_m1,     _li)
    string lm2     = array.get(_t_m2,     _li)
    string lmetric = array.get(_t_metric, _li)
    string lperiod = array.get(_t_period, _li)
    string lup_s   = array.get(_t_up_s,   _li)
    string lup_e   = array.get(_t_up_e,   _li)
    string llo_s   = array.get(_t_lo_s,   _li)
    string llo_e   = array.get(_t_lo_e,   _li)
    string ldir    = array.get(_t_dir,    _li)
    string lbrk    = array.get(_t_brk,    _li)
    string lna     = array.get(_t_na,     _li)

    // ─── Resolve translated tooltips ───
    string tt_hdr_metric = array.get(_tt_hdr_metric, _li)
    string tt_hdr_m1     = array.get(_tt_hdr_m1,     _li)
    string tt_hdr_m2     = array.get(_tt_hdr_m2,     _li)
    string tt_period_lbl = array.get(_tt_period_lbl, _li)
    string tt_period_m1  = array.get(_tt_period_m1,  _li)
    string tt_period_m2  = array.get(_tt_period_m2,  _li)
    string tt_ups_lbl    = array.get(_tt_ups_lbl,    _li)
    string tt_ups_m1     = array.get(_tt_ups_m1,     _li)
    string tt_ups_m2     = array.get(_tt_ups_m2,     _li)
    string tt_upe_lbl    = array.get(_tt_upe_lbl,    _li)
    string tt_upe_m1     = array.get(_tt_upe_m1,     _li)
    string tt_upe_m2     = array.get(_tt_upe_m2,     _li)
    string tt_los_lbl    = array.get(_tt_los_lbl,    _li)
    string tt_los_m1     = array.get(_tt_los_m1,     _li)
    string tt_los_m2     = array.get(_tt_los_m2,     _li)
    string tt_loe_lbl    = array.get(_tt_loe_lbl,    _li)
    string tt_loe_m1     = array.get(_tt_loe_m1,     _li)
    string tt_loe_m2     = array.get(_tt_loe_m2,     _li)
    string tt_dir_lbl    = array.get(_tt_dir_lbl,    _li)
    string tt_dir_m1     = array.get(_tt_dir_m1,     _li)
    string tt_dir_m2     = array.get(_tt_dir_m2,     _li)
    string tt_brk_lbl    = array.get(_tt_brk_lbl,    _li)
    string tt_brk_m1     = array.get(_tt_brk_m1,     _li)
    string tt_brk_m2     = array.get(_tt_brk_m2,     _li)

    // ─── Text alignment: RTL for Arabic, Hebrew, Persian ───
    string halign = _rtl ? text.align_right : text.align_left

    // ─── Color scheme — harmonized with chart themes, accent from channel colors ───
    color hdr_bg   = #1E222D     // Dark header background
    color cell_bg  = #131722     // Dark cell background
    color hdr_txt  = color.white // Header text
    color data_txt = #B2B5BE    // Default data text (light gray)
    color bull_clr = #26A69A     // Bullish green
    color bear_clr = #EF5350     // Bearish red
    color rng_clr  = #787B86     // Range / neutral gray

    // Channel accent colors (trace of each channel's line color)
    color m1_accent = trend_high_color
    color m2_accent = five_hi_color

    // ═══════════════════════════════════════════
    // Extract channel data from line objects
    // (zero modification to drawing logic — reads via line.get_*)
    // ═══════════════════════════════════════════

    // ─── Method 1: Pivot Span Trendline ───
    bool m1_has_hi = not na(high_trend_line_id)
    bool m1_has_lo = not na(low_trend_line_id)
    bool m1_active = m1_has_hi and m1_has_lo

    float m1_y1_hi = m1_has_hi ? line.get_y1(high_trend_line_id) : na
    float m1_y2_hi = m1_has_hi ? line.get_y2(high_trend_line_id) : na
    float m1_y1_lo = m1_has_lo ? line.get_y1(low_trend_line_id)  : na
    float m1_y2_lo = m1_has_lo ? line.get_y2(low_trend_line_id)  : na
    int   m1_x1    = m1_has_hi ? line.get_x1(high_trend_line_id) : na

    // ─── Method 2: 5-Point Straight Channel ───
    bool m2_has_hi = not na(hi_line_5pt)
    bool m2_has_lo = not na(lo_line_5pt)
    bool m2_active = m2_has_hi and m2_has_lo

    float m2_y1_hi = m2_has_hi ? line.get_y1(hi_line_5pt) : na
    float m2_y2_hi = m2_has_hi ? line.get_y2(hi_line_5pt) : na
    float m2_y1_lo = m2_has_lo ? line.get_y1(lo_line_5pt) : na
    float m2_y2_lo = m2_has_lo ? line.get_y2(lo_line_5pt) : na
    int   m2_x1    = m2_has_hi ? line.get_x1(hi_line_5pt) : na

    // ═══════════════════════════════════════════
    // Compute Period Dates (includes year for unambiguous display)
    // ═══════════════════════════════════════════
    string m1_date = lna
    if m1_active and not na(m1_x1)
        int m1_bb = bar_index - m1_x1
        if m1_bb >= 0
            string d1 = str.format_time(time[m1_bb], "MMM dd, yyyy", syminfo.timezone)
            string d2 = str.format_time(time,        "MMM dd, yyyy", syminfo.timezone)
            m1_date := d1 + "\n→ " + d2

    string m2_date = lna
    if m2_active and not na(m2_x1)
        int m2_bb = bar_index - m2_x1
        if m2_bb >= 0
            string d1 = str.format_time(time[m2_bb], "MMM dd, yyyy", syminfo.timezone)
            string d2 = str.format_time(time,        "MMM dd, yyyy", syminfo.timezone)
            m2_date := d1 + "\n→ " + d2

    // ═══════════════════════════════════════════
    // Direction Classification (Midline Slope %)
    // Method: compute midline at start and end of channel,
    // then percentage change. Compare against threshold.
    // Reference: Bulkowski's channel direction classification
    // and Murphy's "Technical Analysis of the Financial Markets".
    // ═══════════════════════════════════════════
    string m1_dir_txt = lna
    color  m1_dir_clr = rng_clr
    if m1_active
        float m1_mid_s = (nz(m1_y1_hi) + nz(m1_y1_lo)) / 2.0
        float m1_mid_e = (nz(m1_y2_hi) + nz(m1_y2_lo)) / 2.0
        float m1_pct   = m1_mid_s != 0.0 ? (m1_mid_e - m1_mid_s) / math.abs(m1_mid_s) * 100.0 : 0.0
        if m1_pct > dash_threshold
            m1_dir_txt := array.get(_t_bull, _li)
            m1_dir_clr := bull_clr
        else if m1_pct < -dash_threshold
            m1_dir_txt := array.get(_t_bear, _li)
            m1_dir_clr := bear_clr
        else
            m1_dir_txt := array.get(_t_rng, _li)
            m1_dir_clr := rng_clr

    string m2_dir_txt = lna
    color  m2_dir_clr = rng_clr
    if m2_active
        float m2_mid_s = (nz(m2_y1_hi) + nz(m2_y1_lo)) / 2.0
        float m2_mid_e = (nz(m2_y2_hi) + nz(m2_y2_lo)) / 2.0
        float m2_pct   = m2_mid_s != 0.0 ? (m2_mid_e - m2_mid_s) / math.abs(m2_mid_s) * 100.0 : 0.0
        if m2_pct > dash_threshold
            m2_dir_txt := array.get(_t_bull, _li)
            m2_dir_clr := bull_clr
        else if m2_pct < -dash_threshold
            m2_dir_txt := array.get(_t_bear, _li)
            m2_dir_clr := bear_clr
        else
            m2_dir_txt := array.get(_t_rng, _li)
            m2_dir_clr := rng_clr

    // ═══════════════════════════════════════════
    // Breakout Detection (close vs channel at current bar)
    // y2_hi / y2_lo are the channel values at bar_index (current bar).
    // ═══════════════════════════════════════════
    string m1_brk_txt = lna
    color  m1_brk_clr = rng_clr
    if m1_active
        if close > m1_y2_hi
            m1_brk_txt := array.get(_t_above, _li)
            m1_brk_clr := bull_clr
        else if close < m1_y2_lo
            m1_brk_txt := array.get(_t_below, _li)
            m1_brk_clr := bear_clr
        else
            m1_brk_txt := array.get(_t_inside, _li)
            m1_brk_clr := rng_clr

    string m2_brk_txt = lna
    color  m2_brk_clr = rng_clr
    if m2_active
        if close > m2_y2_hi
            m2_brk_txt := array.get(_t_above, _li)
            m2_brk_clr := bull_clr
        else if close < m2_y2_lo
            m2_brk_txt := array.get(_t_below, _li)
            m2_brk_clr := bear_clr
        else
            m2_brk_txt := array.get(_t_inside, _li)
            m2_brk_clr := rng_clr

    // ═══════════════════════════════════════════
    // Format price values using symbol precision
    // ═══════════════════════════════════════════
    string m1_us = m1_active ? str.tostring(m1_y1_hi, format.mintick) : lna
    string m1_ue = m1_active ? str.tostring(m1_y2_hi, format.mintick) : lna
    string m1_ls = m1_active ? str.tostring(m1_y1_lo, format.mintick) : lna
    string m1_le = m1_active ? str.tostring(m1_y2_lo, format.mintick) : lna

    string m2_us = m2_active ? str.tostring(m2_y1_hi, format.mintick) : lna
    string m2_ue = m2_active ? str.tostring(m2_y2_hi, format.mintick) : lna
    string m2_ls = m2_active ? str.tostring(m2_y1_lo, format.mintick) : lna
    string m2_le = m2_active ? str.tostring(m2_y2_lo, format.mintick) : lna

    // ═══════════════════════════════════════════
    // Build Table — 3 columns × 8 rows
    // ═══════════════════════════════════════════
    // Row 0: Headers  (Metric | Pivot Span | 5-Pt Channel)
    // Row 1: Period   (date → date)
    // Row 2: Upper Start
    // Row 3: Upper End
    // Row 4: Lower Start
    // Row 5: Lower End
    // Row 6: Direction
    // Row 7: Breakout

    dash_table := table.new(
         getDashPos(dash_pos), 3, 8,
         bgcolor      = cell_bg,
         border_color = color.new(#363A45, 50),
         border_width = 1)

    // ─── Row 0: Column Headers ───
    table.cell(dash_table, 0, 0, lmetric,
         bgcolor    = hdr_bg,
         text_color = hdr_txt,
         text_size  = dash_font,
         text_halign     = halign,
         text_formatting = text.format_bold,
         tooltip    = tt_hdr_metric)

    // Append configured lookback bar count to Method 1 header label
    string lm1_display = lm1 + " (" + str.tostring(length_input) + ")"
    table.cell(dash_table, 1, 0, lm1_display,
         bgcolor    = hdr_bg,
         text_color = m1_accent,
         text_size  = dash_font,
         text_halign     = halign,
         text_formatting = text.format_bold,
         tooltip    = tt_hdr_m1)

    // Append configured channel length bar count to Method 2 header label
    string lm2_display = lm2 + " (" + str.tostring(len_channel_5pt) + ")"
    table.cell(dash_table, 2, 0, lm2_display,
         bgcolor    = hdr_bg,
         text_color = m2_accent,
         text_size  = dash_font,
         text_halign     = halign,
         text_formatting = text.format_bold,
         tooltip    = tt_hdr_m2)

    // ─── Row 1: Period ───
    table.cell(dash_table, 0, 1, lperiod,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_period_lbl)

    table.cell(dash_table, 1, 1, m1_date,
         bgcolor = cell_bg, text_color = data_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_period_m1)

    table.cell(dash_table, 2, 1, m2_date,
         bgcolor = cell_bg, text_color = data_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_period_m2)

    // ─── Row 2: Upper Start ───
    table.cell(dash_table, 0, 2, lup_s,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_ups_lbl)

    table.cell(dash_table, 1, 2, m1_us,
         bgcolor = cell_bg, text_color = m1_active ? m1_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_ups_m1)

    table.cell(dash_table, 2, 2, m2_us,
         bgcolor = cell_bg, text_color = m2_active ? m2_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_ups_m2)

    // ─── Row 3: Upper End ───
    table.cell(dash_table, 0, 3, lup_e,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_upe_lbl)

    table.cell(dash_table, 1, 3, m1_ue,
         bgcolor = cell_bg, text_color = m1_active ? m1_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_upe_m1)

    table.cell(dash_table, 2, 3, m2_ue,
         bgcolor = cell_bg, text_color = m2_active ? m2_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_upe_m2)

    // ─── Row 4: Lower Start ───
    table.cell(dash_table, 0, 4, llo_s,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_los_lbl)

    table.cell(dash_table, 1, 4, m1_ls,
         bgcolor = cell_bg, text_color = m1_active ? m1_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_los_m1)

    table.cell(dash_table, 2, 4, m2_ls,
         bgcolor = cell_bg, text_color = m2_active ? m2_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_los_m2)

    // ─── Row 5: Lower End ───
    table.cell(dash_table, 0, 5, llo_e,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_loe_lbl)

    table.cell(dash_table, 1, 5, m1_le,
         bgcolor = cell_bg, text_color = m1_active ? m1_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_loe_m1)

    table.cell(dash_table, 2, 5, m2_le,
         bgcolor = cell_bg, text_color = m2_active ? m2_accent : rng_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_loe_m2)

    // ─── Row 6: Direction ───
    table.cell(dash_table, 0, 6, ldir,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_dir_lbl)

    table.cell(dash_table, 1, 6, m1_dir_txt,
         bgcolor = cell_bg, text_color = m1_dir_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_dir_m1)

    table.cell(dash_table, 2, 6, m2_dir_txt,
         bgcolor = cell_bg, text_color = m2_dir_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_dir_m2)

    // ─── Row 7: Breakout ───
    table.cell(dash_table, 0, 7, lbrk,
         bgcolor = hdr_bg, text_color = hdr_txt, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_brk_lbl)

    table.cell(dash_table, 1, 7, m1_brk_txt,
         bgcolor = cell_bg, text_color = m1_brk_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_brk_m1)

    table.cell(dash_table, 2, 7, m2_brk_txt,
         bgcolor = cell_bg, text_color = m2_brk_clr, text_size = dash_font,
         text_halign = halign,
         tooltip = tt_brk_m2)

//══════════════════════════════════════════════════════════════════════════════════
// ─── GUIDELINES
//══════════════════════════════════════════════════════════════════════════════════
// • Pine Script v6 (//@version=6). Overlay indicator.
// • Method 1 (Pivot Span Trendline): detects pivot highs/lows, stores up to
//   point_count_input pivots, draws a linear interpolation line between the
//   first and last stored pivots for both high and low. Fills between lines.
// • Method 2 (5-Point Straight Channel): divides the lookback window into 5
//   equal segments, picks the highest high and lowest low in each segment,
//   then fits an OLS linear regression to those 5 anchor points independently
//   for the upper and lower boundaries.
// • Dashboard reads channel data directly from line objects via line.get_y1/y2/x1
//   — zero modification to any drawing logic.
// • Dashboard tooltips are fully translated into all 13 supported languages
//   using dedicated translation arrays (_tt_*), resolved at render time via
//   the same language index (_li) used for labels.
// • Direction classification uses the midline percentage change:
//   midline = (upper_y + lower_y) / 2 at start and end of the channel.
//   pct = (mid_end - mid_start) / |mid_start| × 100.
//   Compared against a user-configurable threshold (default 0.5%,
//   per Bulkowski/Murphy standard channel classification methodology).
// • Breakout detection compares close vs the channel upper/lower values at
//   the current bar (y2 endpoints of each line).
// • Translation engine uses array-indexed lookup for 13 languages.
//   RTL alignment is automatically enforced for Arabic, Hebrew, and Persian.
// • Date format includes year (MMM dd, yyyy) for unambiguous cross-year display.
// • Numeric font size (integer pt) is passed directly to table.cell() text_size,
//   following Pine v6 support for numeric text sizing. No artificial upper cap;
//   only TradingView's own rendering limits apply.
// • All table.cell() calls include translated tooltip parameters matching
//   the selected dashboard language.
// • No external indicators or data sources are used.
//══════════════════════════════════════════════════════════════════════════════════
````
