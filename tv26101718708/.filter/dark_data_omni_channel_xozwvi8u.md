# [Dark Data] Omni Channel

- url: https://www.tradingview.com/script/XOzWvI8U-Dark-Data-Omni-Channel/
- type: indicator
- pine_id: PUB;912584818ef94dc4a5d3ed3051736a31
- version: 2.0

## Description

[b]Objective[/b]
A toolkit to create a variety of custom channels.

[b]Theory[/b]
Channels offer a visual aid in understanding the state and price structure of an asset.

[b]How To Use[/b]
Select a Basis Type around which the bands will be measured, and set the relevant input(s) (e.g. Basis Type = Moving Average and Moving Average: Period = 20).
Select Number of Bands and Band Type. The distance between each band will be based on your chosen type and relevant band input(s) (e.g. Number of Bands = 1 Band, Band Type = Std Dev, Std Dev: Period = 20, Std Dev: Deviations = 2).

[image]https://www.tradingview.com/x/DY0ZmqAH/[/image]

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright DarkData_Official

//@version=6
indicator("[Dark Data] Omni Channel", shorttitle="Omni Channel", overlay = true)

// ═══════════════════════════════════════════
//  BASIS SETTINGS
// ═══════════════════════════════════════════
var string GRP_BASIS = "Basis"

basis_type = input.string(
     title    = "Basis Type",
     defval   = "Moving Average",
     options  = ["Moving Average", "Candle Open", "VWAP", "Linear Regression", "Polynomial Regression"],
     group    = GRP_BASIS
     )

ma_period = input.int(
     title    = "Moving Average: Period",
     defval   = 20,
     minval   = 1,
     group    = GRP_BASIS
     )

candle_open_tf = input.timeframe(
     title    = "Candle Open: Timeframe",
     defval   = "D",
     group    = GRP_BASIS
     )

vwap_anchor = input.string(
     title    = "VWAP: Anchor",
     defval   = "Day",
     options  = ["Day", "Week", "Month", "Period"],
     group    = GRP_BASIS
     )

vwap_period = input.int(
     title    = "VWAP: Period",
     defval   = 20,
     minval   = 1,
     group    = GRP_BASIS,
     tooltip  = "Only used when VWAP: Anchor is set to 'Period'."
     )

linreg_period = input.int(
     title    = "Linear Regression: Period",
     defval   = 20,
     minval   = 2,
     group    = GRP_BASIS
     )

polyreg_period = input.int(
     title    = "Polynomial Regression: Period",
     defval   = 50,
     minval   = 3,
     group    = GRP_BASIS
     )

polyreg_degree = input.int(
     title    = "Polynomial Regression: Degree",
     defval   = 2,
     minval   = 2,
     maxval   = 6,
     group    = GRP_BASIS
     )

// ═══════════════════════════════════════════
//  BAND SETTINGS
// ═══════════════════════════════════════════
var string GRP_BANDS = "Bands"

num_bands = input.string(
     title   = "Number Of Bands",
     defval  = "2 Bands",
     options = ["None", "1 Band", "2 Bands", "3 Bands", "4 Bands", "5 Bands"],
     group   = GRP_BANDS
     )

band_type = input.string(
     title    = "Band Type",
     defval   = "Percent",
     options  = ["Pips", "Percent", "ATR", "Std Dev"],
     group    = GRP_BANDS
     )

band_pips = input.float(
     title    = "Pips",
     defval   = 10.0,
     minval   = 0.0,
     group    = GRP_BANDS
     )

band_percent = input.float(
     title    = "Percent",
     defval   = 1.0,
     minval   = 0.0,
     step     = 0.1,
     group    = GRP_BANDS
     )

atr_period = input.int(
     title    = "ATR: Period",
     defval   = 14,
     minval   = 1,
     group    = GRP_BANDS
     )

atr_mult = input.float(
     title    = "ATR: Multiplier",
     defval   = 3.0,
     minval   = 0.1,
     step     = 0.1,
     group    = GRP_BANDS
     )

stdev_period = input.int(
     title    = "Std Dev: Period",
     defval   = 20,
     minval   = 2,
     group    = GRP_BANDS
     )

stdev_mult = input.float(
     title    = "Std Dev: Deviations",
     defval   = 2.0,
     minval   = 0.1,
     step     = 0.1,
     group    = GRP_BANDS
     )

// ═══════════════════════════════════════════
//  VISUALS SETTINGS
// ═══════════════════════════════════════════
var string GRP_VISUALS = "Visuals"

show_fills = input.bool(
     title   = "Show Fills",
     defval  = true,
     group   = GRP_VISUALS
     )

// ═══════════════════════════════════════════
//  POLYNOMIAL REGRESSION — precomputed pseudo-inverse
//  b = (XᵀX)⁻¹Xᵀ computed once at init; x normalised to [-1, 1]
//  At barstate.islast: coefficients = b × prices  (one matrix multiply)
// ═══════════════════════════════════════════
var matrix<float> polyreg_b = na

if barstate.isfirst and basis_type == "Polynomial Regression"
    float p_scale = polyreg_period > 1 ? 2.0 / (polyreg_period - 1) : 0.0
    matrix<float> X = matrix.new<float>(polyreg_period, polyreg_degree + 1, 0.0)
    for i = 0 to polyreg_period - 1
        float xi = p_scale * i - 1.0
        float xp = 1.0
        for j = 0 to polyreg_degree
            matrix.set(X, i, j, xp)
            xp *= xi
    matrix<float> Xt = matrix.transpose(X)
    polyreg_b := matrix.mult(matrix.inv(matrix.mult(Xt, X)), Xt)

// ═══════════════════════════════════════════
//  POLYLINE POINT BUILDER
// ═══════════════════════════════════════════
polyreg_pts(fitted, offset) =>
    array<chart.point> pts = array.new<chart.point>()
    for i = 0 to polyreg_period - 1
        array.push(pts, chart.point.from_index(bar_index - (polyreg_period - 1 - i), array.get(fitted, i) + offset))
    pts

// Traces upper_offset boundary forward then lower_offset boundary backward,
// forming a closed shape suitable for polyline fill_color.
polyreg_fill_pts(fitted, upper_offset, lower_offset) =>
    array<chart.point> pts = array.new<chart.point>()
    for i = 0 to polyreg_period - 1
        array.push(pts, chart.point.from_index(bar_index - (polyreg_period - 1 - i), array.get(fitted, i) + upper_offset))
    for i = polyreg_period - 1 to 0
        array.push(pts, chart.point.from_index(bar_index - (polyreg_period - 1 - i), array.get(fitted, i) + lower_offset))
    pts

// ═══════════════════════════════════════════
//  BASE CALCULATION
// ═══════════════════════════════════════════
float candle_open = basis_type == "Candle Open" ? request.security(syminfo.tickerid, candle_open_tf, open, lookahead = barmerge.lookahead_on) : na

var array<float> polyreg_fitted = na

// Computed every bar so ta.linreg buffers correctly; objects only drawn on barstate.islast
float linreg_end_val   = basis_type == "Linear Regression" ? ta.linreg(close, linreg_period, 0)                : na
float linreg_start_val = basis_type == "Linear Regression" ? ta.linreg(close, linreg_period, linreg_period - 1) : na

float base_value = na
if basis_type == "Moving Average"
    base_value := ta.sma(close, ma_period)
else if basis_type == "Candle Open"
    base_value := candle_open
else if basis_type == "VWAP"
    if vwap_anchor == "Period"
        base_value := math.sum(hlc3 * volume, vwap_period) / math.sum(volume, vwap_period)
    else
        bool vwap_reset = switch vwap_anchor
            "Week"  => timeframe.change("W")
            "Month" => timeframe.change("M")
            =>         timeframe.change("D")
        base_value := ta.vwap(hlc3, vwap_reset)
else if basis_type == "Linear Regression"
    base_value := linreg_end_val
else if basis_type == "Polynomial Regression" and barstate.islast and bar_index >= polyreg_period - 1 and not na(polyreg_b)
    matrix<float> p_prices = matrix.new<float>(polyreg_period, 1, 0.0)
    for i = 0 to polyreg_period - 1
        matrix.set(p_prices, i, 0, close[polyreg_period - 1 - i])
    matrix<float> p_coeff = matrix.mult(polyreg_b, p_prices)
    float p_scale = polyreg_period > 1 ? 2.0 / (polyreg_period - 1) : 0.0
    polyreg_fitted := array.new_float(polyreg_period, 0.0)
    for i = 0 to polyreg_period - 1
        float xi  = p_scale * i - 1.0
        float val = 0.0
        float xp  = 1.0
        for k = 0 to polyreg_degree
            val += matrix.get(p_coeff, k, 0) * xp
            xp  *= xi
        array.set(polyreg_fitted, i, val)
    base_value := array.get(polyreg_fitted, polyreg_period - 1)

// ═══════════════════════════════════════════
//  BAND CALCULATION
// ═══════════════════════════════════════════
float band_offset = na
if band_type == "Pips"
    band_offset := band_pips * (syminfo.type == "forex" ? syminfo.mintick * 10 : syminfo.mintick)
else if band_type == "Percent"
    band_offset := base_value * (band_percent / 100)
else if band_type == "ATR"
    band_offset := ta.atr(atr_period) * atr_mult
else if band_type == "Std Dev"
    band_offset := ta.stdev(close, stdev_period) * stdev_mult

// ═══════════════════════════════════════════
//  BAND VALUES
// ═══════════════════════════════════════════
bool is_linreg   = basis_type == "Linear Regression"
bool is_polyreg  = basis_type == "Polynomial Regression"
bool use_objects = is_linreg or is_polyreg

int bands_count = switch num_bands
    "1 Band"  => 1
    "2 Bands" => 2
    "3 Bands" => 3
    "4 Bands" => 4
    "5 Bands" => 5
    => 0

float upper_2 = (bands_count >= 2 and not use_objects) ? base_value + band_offset * 2 : na
float lower_2 = (bands_count >= 2 and not use_objects) ? base_value - band_offset * 2 : na
float upper_3 = (bands_count >= 3 and not use_objects) ? base_value + band_offset * 3 : na
float lower_3 = (bands_count >= 3 and not use_objects) ? base_value - band_offset * 3 : na
float upper_4 = (bands_count >= 4 and not use_objects) ? base_value + band_offset * 4 : na
float lower_4 = (bands_count >= 4 and not use_objects) ? base_value - band_offset * 4 : na
float upper_5 = (bands_count >= 5 and not use_objects) ? base_value + band_offset * 5 : na
float lower_5 = (bands_count >= 5 and not use_objects) ? base_value - band_offset * 5 : na

// ═══════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════

// Pips — teal
color pip_b1 = #9FE1CB
color pip_b2 = #5DCAA5
color pip_b3 = #1D9E75
color pip_b4 = #0F6E56
color pip_b5 = #085041

// Percent — pink
color pct_b1 = #F4C0D1
color pct_b2 = #ED93B1
color pct_b3 = #D4537E
color pct_b4 = #993556
color pct_b5 = #72243E

// ATR — purple
color atr_b1 = #CECBF6
color atr_b2 = #AFA9EC
color atr_b3 = #7F77DD
color atr_b4 = #534AB7
color atr_b5 = #3C3489

// Std Dev — blue
color std_b1 = #B5D4F4
color std_b2 = #85B7EB
color std_b3 = #378ADD
color std_b4 = #185FA5
color std_b5 = #0C447C

color col_basis = #FF006E

color col_b1 = switch band_type
    "Pips"    => pip_b1
    "Percent" => pct_b1
    "ATR"     => atr_b1
    => std_b1

color col_b2 = switch band_type
    "Pips"    => pip_b2
    "Percent" => pct_b2
    "ATR"     => atr_b2
    => std_b2

color col_b3 = switch band_type
    "Pips"    => pip_b3
    "Percent" => pct_b3
    "ATR"     => atr_b3
    => std_b3

color col_b4 = switch band_type
    "Pips"    => pip_b4
    "Percent" => pct_b4
    "ATR"     => atr_b4
    => std_b4

color col_b5 = switch band_type
    "Pips"    => pip_b5
    "Percent" => pct_b5
    "ATR"     => atr_b5
    => std_b5

color fill_b1 = color.new(col_b1, 85)
color fill_b2 = color.new(col_b2, 85)
color fill_b3 = color.new(col_b3, 85)
color fill_b4 = color.new(col_b4, 85)
color fill_b5 = color.new(col_b5, 85)

// Linear regression line objects
var line reg_line = na
var line upper_l1 = na
var line lower_l1 = na
var line upper_l2 = na
var line lower_l2 = na
var line upper_l3 = na
var line lower_l3 = na
var line upper_l4 = na
var line lower_l4 = na
var line upper_l5 = na
var line lower_l5 = na

// Linear regression fill objects (one per adjacent band pair, upper and lower)
var linefill lf_base_u1 = na
var linefill lf_base_l1 = na
var linefill lf_u1_u2   = na
var linefill lf_l1_l2   = na
var linefill lf_u2_u3   = na
var linefill lf_l2_l3   = na
var linefill lf_u3_u4   = na
var linefill lf_l3_l4   = na
var linefill lf_u4_u5   = na
var linefill lf_l4_l5   = na

// Polynomial regression polyline objects
var polyline poly_reg = na
var polyline poly_u1  = na
var polyline poly_l1  = na
var polyline poly_u2  = na
var polyline poly_l2  = na
var polyline poly_u3  = na
var polyline poly_l3  = na
var polyline poly_u4  = na
var polyline poly_l4  = na
var polyline poly_u5  = na
var polyline poly_l5  = na

// Polynomial regression fill polylines (closed shapes between adjacent band pairs)
var polyline poly_fill_base_u1 = na
var polyline poly_fill_base_l1 = na
var polyline poly_fill_u1_u2   = na
var polyline poly_fill_l1_l2   = na
var polyline poly_fill_u2_u3   = na
var polyline poly_fill_l2_l3   = na
var polyline poly_fill_u3_u4   = na
var polyline poly_fill_l3_l4   = na
var polyline poly_fill_u4_u5   = na
var polyline poly_fill_l4_l5   = na

if is_linreg and barstate.islast and bar_index >= linreg_period - 1
    int   x1        = bar_index - linreg_period + 1
    int   x2        = bar_index
    float reg_end   = linreg_end_val
    float reg_start = linreg_start_val

    // Delete fills first (must precede line deletion)
    linefill.delete(lf_base_u1)
    linefill.delete(lf_base_l1)
    linefill.delete(lf_u1_u2)
    linefill.delete(lf_l1_l2)
    linefill.delete(lf_u2_u3)
    linefill.delete(lf_l2_l3)
    linefill.delete(lf_u3_u4)
    linefill.delete(lf_l3_l4)
    linefill.delete(lf_u4_u5)
    linefill.delete(lf_l4_l5)

    // Delete lines
    line.delete(reg_line)
    line.delete(upper_l1)
    line.delete(lower_l1)
    line.delete(upper_l2)
    line.delete(lower_l2)
    line.delete(upper_l3)
    line.delete(lower_l3)
    line.delete(upper_l4)
    line.delete(lower_l4)
    line.delete(upper_l5)
    line.delete(lower_l5)

    // Create basis line
    reg_line := line.new(x1 = x1, y1 = reg_start, x2 = x2, y2 = reg_end, color = col_basis, width = 1)

    // Create band lines and fills between adjacent pairs
    if bands_count >= 1
        upper_l1 := line.new(x1 = x1, y1 = reg_start + band_offset,     x2 = x2, y2 = reg_end + band_offset,     color = col_b1, width = 1)
        lower_l1 := line.new(x1 = x1, y1 = reg_start - band_offset,     x2 = x2, y2 = reg_end - band_offset,     color = col_b1, width = 1)
        if show_fills
            lf_base_u1 := linefill.new(reg_line, upper_l1, fill_b1)
            lf_base_l1 := linefill.new(reg_line, lower_l1, fill_b1)
    if bands_count >= 2
        upper_l2 := line.new(x1 = x1, y1 = reg_start + band_offset * 2, x2 = x2, y2 = reg_end + band_offset * 2, color = col_b2, width = 1)
        lower_l2 := line.new(x1 = x1, y1 = reg_start - band_offset * 2, x2 = x2, y2 = reg_end - band_offset * 2, color = col_b2, width = 1)
        if show_fills
            lf_u1_u2 := linefill.new(upper_l1, upper_l2, fill_b2)
            lf_l1_l2 := linefill.new(lower_l1, lower_l2, fill_b2)
    if bands_count >= 3
        upper_l3 := line.new(x1 = x1, y1 = reg_start + band_offset * 3, x2 = x2, y2 = reg_end + band_offset * 3, color = col_b3, width = 1)
        lower_l3 := line.new(x1 = x1, y1 = reg_start - band_offset * 3, x2 = x2, y2 = reg_end - band_offset * 3, color = col_b3, width = 1)
        if show_fills
            lf_u2_u3 := linefill.new(upper_l2, upper_l3, fill_b3)
            lf_l2_l3 := linefill.new(lower_l2, lower_l3, fill_b3)
    if bands_count >= 4
        upper_l4 := line.new(x1 = x1, y1 = reg_start + band_offset * 4, x2 = x2, y2 = reg_end + band_offset * 4, color = col_b4, width = 1)
        lower_l4 := line.new(x1 = x1, y1 = reg_start - band_offset * 4, x2 = x2, y2 = reg_end - band_offset * 4, color = col_b4, width = 1)
        if show_fills
            lf_u3_u4 := linefill.new(upper_l3, upper_l4, fill_b4)
            lf_l3_l4 := linefill.new(lower_l3, lower_l4, fill_b4)
    if bands_count >= 5
        upper_l5 := line.new(x1 = x1, y1 = reg_start + band_offset * 5, x2 = x2, y2 = reg_end + band_offset * 5, color = col_b5, width = 1)
        lower_l5 := line.new(x1 = x1, y1 = reg_start - band_offset * 5, x2 = x2, y2 = reg_end - band_offset * 5, color = col_b5, width = 1)
        if show_fills
            lf_u4_u5 := linefill.new(upper_l4, upper_l5, fill_b5)
            lf_l4_l5 := linefill.new(lower_l4, lower_l5, fill_b5)

else if is_polyreg and barstate.islast and not na(polyreg_fitted)
    // Delete fills
    polyline.delete(poly_fill_base_u1)
    polyline.delete(poly_fill_base_l1)
    polyline.delete(poly_fill_u1_u2)
    polyline.delete(poly_fill_l1_l2)
    polyline.delete(poly_fill_u2_u3)
    polyline.delete(poly_fill_l2_l3)
    polyline.delete(poly_fill_u3_u4)
    polyline.delete(poly_fill_l3_l4)
    polyline.delete(poly_fill_u4_u5)
    polyline.delete(poly_fill_l4_l5)

    // Delete band lines
    polyline.delete(poly_reg)
    poly_reg := polyline.new(polyreg_pts(polyreg_fitted,  0.0),            line_color = col_basis, line_width = 1)
    polyline.delete(poly_u1)
    polyline.delete(poly_l1)
    if bands_count >= 1
        poly_u1 := polyline.new(polyreg_pts(polyreg_fitted,  band_offset),     line_color = col_b1, line_width = 1)
        poly_l1 := polyline.new(polyreg_pts(polyreg_fitted, -band_offset),     line_color = col_b1, line_width = 1)
        if show_fills
            poly_fill_base_u1 := polyline.new(polyreg_fill_pts(polyreg_fitted,  band_offset,       0.0          ), closed = true, fill_color = fill_b1, line_color = color.new(color.white, 100))
            poly_fill_base_l1 := polyline.new(polyreg_fill_pts(polyreg_fitted,  0.0,              -band_offset  ), closed = true, fill_color = fill_b1, line_color = color.new(color.white, 100))
    polyline.delete(poly_u2)
    polyline.delete(poly_l2)
    if bands_count >= 2
        poly_u2 := polyline.new(polyreg_pts(polyreg_fitted,  band_offset * 2), line_color = col_b2, line_width = 1)
        poly_l2 := polyline.new(polyreg_pts(polyreg_fitted, -band_offset * 2), line_color = col_b2, line_width = 1)
        if show_fills
            poly_fill_u1_u2 := polyline.new(polyreg_fill_pts(polyreg_fitted,  band_offset * 2,   band_offset   ), closed = true, fill_color = fill_b2, line_color = color.new(color.white, 100))
            poly_fill_l1_l2 := polyline.new(polyreg_fill_pts(polyreg_fitted, -band_offset,      -band_offset * 2), closed = true, fill_color = fill_b2, line_color = color.new(color.white, 100))
    polyline.delete(poly_u3)
    polyline.delete(poly_l3)
    if bands_count >= 3
        poly_u3 := polyline.new(polyreg_pts(polyreg_fitted,  band_offset * 3), line_color = col_b3, line_width = 1)
        poly_l3 := polyline.new(polyreg_pts(polyreg_fitted, -band_offset * 3), line_color = col_b3, line_width = 1)
        if show_fills
            poly_fill_u2_u3 := polyline.new(polyreg_fill_pts(polyreg_fitted,  band_offset * 3,   band_offset * 2), closed = true, fill_color = fill_b3, line_color = color.new(color.white, 100))
            poly_fill_l2_l3 := polyline.new(polyreg_fill_pts(polyreg_fitted, -band_offset * 2,  -band_offset * 3), closed = true, fill_color = fill_b3, line_color = color.new(color.white, 100))
    polyline.delete(poly_u4)
    polyline.delete(poly_l4)
    if bands_count >= 4
        poly_u4 := polyline.new(polyreg_pts(polyreg_fitted,  band_offset * 4), line_color = col_b4, line_width = 1)
        poly_l4 := polyline.new(polyreg_pts(polyreg_fitted, -band_offset * 4), line_color = col_b4, line_width = 1)
        if show_fills
            poly_fill_u3_u4 := polyline.new(polyreg_fill_pts(polyreg_fitted,  band_offset * 4,   band_offset * 3), closed = true, fill_color = fill_b4, line_color = color.new(color.white, 100))
            poly_fill_l3_l4 := polyline.new(polyreg_fill_pts(polyreg_fitted, -band_offset * 3,  -band_offset * 4), closed = true, fill_color = fill_b4, line_color = color.new(color.white, 100))
    polyline.delete(poly_u5)
    polyline.delete(poly_l5)
    if bands_count >= 5
        poly_u5 := polyline.new(polyreg_pts(polyreg_fitted,  band_offset * 5), line_color = col_b5, line_width = 1)
        poly_l5 := polyline.new(polyreg_pts(polyreg_fitted, -band_offset * 5), line_color = col_b5, line_width = 1)
        if show_fills
            poly_fill_u4_u5 := polyline.new(polyreg_fill_pts(polyreg_fitted,  band_offset * 5,   band_offset * 4), closed = true, fill_color = fill_b5, line_color = color.new(color.white, 100))
            poly_fill_l4_l5 := polyline.new(polyreg_fill_pts(polyreg_fitted, -band_offset * 4,  -band_offset * 5), closed = true, fill_color = fill_b5, line_color = color.new(color.white, 100))

p_base   = plot(use_objects ? na : base_value,                                           title = "Base",         color = col_basis, linewidth = 1)
p_upper1 = plot((bands_count >= 1 and not use_objects) ? base_value + band_offset : na, title = "Upper Band 1", color = col_b1,    linewidth = 1)
p_lower1 = plot((bands_count >= 1 and not use_objects) ? base_value - band_offset : na, title = "Lower Band 1", color = col_b1,    linewidth = 1)
p_upper2 = plot(upper_2, title = "Upper Band 2", color = col_b2, linewidth = 1)
p_lower2 = plot(lower_2, title = "Lower Band 2", color = col_b2, linewidth = 1)
p_upper3 = plot(upper_3, title = "Upper Band 3", color = col_b3, linewidth = 1)
p_lower3 = plot(lower_3, title = "Lower Band 3", color = col_b3, linewidth = 1)
p_upper4 = plot(upper_4, title = "Upper Band 4", color = col_b4, linewidth = 1)
p_lower4 = plot(lower_4, title = "Lower Band 4", color = col_b4, linewidth = 1)
p_upper5 = plot(upper_5, title = "Upper Band 5", color = col_b5, linewidth = 1)
p_lower5 = plot(lower_5, title = "Lower Band 5", color = col_b5, linewidth = 1)

fill(p_base,   p_upper1, color = show_fills ? fill_b1 : na)
fill(p_base,   p_lower1, color = show_fills ? fill_b1 : na)
fill(p_upper1, p_upper2, color = show_fills ? fill_b2 : na)
fill(p_lower1, p_lower2, color = show_fills ? fill_b2 : na)
fill(p_upper2, p_upper3, color = show_fills ? fill_b3 : na)
fill(p_lower2, p_lower3, color = show_fills ? fill_b3 : na)
fill(p_upper3, p_upper4, color = show_fills ? fill_b4 : na)
fill(p_lower3, p_lower4, color = show_fills ? fill_b4 : na)
fill(p_upper4, p_upper5, color = show_fills ? fill_b5 : na)
fill(p_lower4, p_lower5, color = show_fills ? fill_b5 : na)
````
