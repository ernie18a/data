# Quant H - TradeRR

- url: https://www.tradingview.com/script/dOqAZE4E-Quant-H-TradeRR/
- type: indicator
- pine_id: PUB;52678c8366a74004bb7acd50417b92b4
- version: 1.0

## Description

Quant H - TradeRR

Quant H - TradeRR is a visual regime indicator that classifies market conditions into three states: Bull, Bear, and Sideways. It uses a rolling log-return model to label each bar, then builds a live transition matrix from chart history so you can see how likely the market is to remain in the current regime or shift into another one.

The core idea is simple: markets tend to move in persistent states, and those states can be measured. This script turns that into a clean on-chart framework by showing both the current regime and the probability structure behind it.

What it does

* Labels each bar as Bull, Bear, or Sideways
* Builds a live Markov transition matrix from visible chart history
* Highlights regime persistence through the diagonal probabilities
* Estimates the stationary distribution, showing the long-run regime mix
* Marks durable regime transitions directly on the chart
* Adds a subtle background ribbon so regime shifts are easy to spot visually

How to use it

* Best used on higher timeframes like 4H, Daily, and Weekly
* Works especially well on trending assets like indices, crypto, and liquid large caps
* Adjust the lookback window and thresholds to make regime detection tighter or looser
* Watch the diagonal of the matrix closely: higher diagonal values suggest stronger regime persistence

How to read it

* Bull: positive rolling return above the chosen threshold
* Bear: negative rolling return below the chosen threshold
* Sideways: anything in between
* Transition matrix: probability of moving from one regime to another
* Stationary distribution: the long-run baseline mix of Bull/Bear/Sideways regimes

Why it matters
Most indicators only tell you what price is doing now. This one helps frame what state the market is in, how sticky that state has been, and how often transitions happen. It is designed to support regime awareness, not replace your execution model.

Notes

* This is a probabilistic framework, not a prediction engine
* Results depend on the visible chart history and your chosen parameters
* Best used alongside structure, trend, volatility, and risk management

Disclaimer
This script is for educational and research purposes only. It is not financial advice.

## Source Code

````pine
//@version=6
// =============================================================================
// Quant H - TradeRR
// =============================================================================

indicator("Quant H - TradeRR", overlay = true, max_labels_count = 500)

// Inputs
grp_logic    = "Regime logic"
grp_display  = "Display"
grp_position = "Table positions"

lookback_window    = input.int(20, title = "Lookback window (bars)", minval = 5, maxval = 250, group = grp_logic)
bull_threshold_pct = input.float(5.0, title = "Bull threshold (%)", minval = 0.1, maxval = 50.0, step = 0.1, group = grp_logic)
bear_threshold_pct = input.float(5.0, title = "Bear threshold (%)", minval = 0.1, maxval = 50.0, step = 0.1, group = grp_logic)
stationary_power   = input.int(50, title = "Stationary power (iterations)", minval = 10, maxval = 200, group = grp_logic)

show_regime_ribbon     = input.bool(true, title = "Show regime ribbon", group = grp_display)
show_regime_banner     = input.bool(true, title = "Show current-regime banner", group = grp_display)
show_matrix_table      = input.bool(true, title = "Show transition matrix", group = grp_display)
show_stationary_table  = input.bool(true, title = "Show stationary distribution", group = grp_display)
show_transition_labels = input.bool(true, title = "Label state transitions on chart", group = grp_display)
table_text_size        = input.string("normal", title = "Table text size", options = ["small", "normal", "large", "huge"], group = grp_display)
min_regime_hold        = input.int(4, title = "Min bars a regime must hold to be labelled", minval = 1, maxval = 50, group = grp_display)

banner_position_input     = input.string("top_left", title = "Banner position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group = grp_position)
matrix_position_input     = input.string("top_right", title = "Matrix position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group = grp_position)
stationary_position_input = input.string("bottom_right", title = "Stationary position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group = grp_position)

// Position mapping
position_from_string(s) =>
    switch s
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.top_right

banner_pos     = position_from_string(banner_position_input)
matrix_pos     = position_from_string(matrix_position_input)
stationary_pos = position_from_string(stationary_position_input)

size_from_string(s) =>
    switch s
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.normal

notch_down(s) =>
    switch s
        "huge"   => "large"
        "large"  => "normal"
        "normal" => "small"
        => "small"

val_size = size_from_string(table_text_size)
hdr_size = size_from_string(notch_down(table_text_size))

// Palette
c_bull_ribbon = color.rgb(132, 187, 161, 70)
c_bear_ribbon = color.rgb(197, 127, 134, 70)
c_side_ribbon = color.rgb(164, 171, 183, 70)

c_bull_solid  = color.rgb(132, 187, 161, 30)
c_bear_solid  = color.rgb(197, 127, 134, 30)
c_side_solid  = color.rgb(164, 171, 183, 30)

c_bg          = color.new(color.black, 30)
c_text_active = color.white
c_card_bg     = color.new(#0B0F0D, 8)
c_card_frame  = color.new(#3FDE7E, 78)
c_accent      = #3FDE7E
c_diag_bg     = color.new(#3FDE7E, 80)
c_diag_txt    = #6BF0A6
c_off_txt     = color.new(color.white, 55)
c_hdr_txt     = color.new(color.white, 35)

regime_solid(r) => r == 1 ? c_bull_solid : r == 2 ? c_bear_solid : c_side_solid
regime_name(r)  => r == 1 ? "Bull" : r == 2 ? "Bear" : "Sideways"
regime_abbr(r)  => r == 1 ? "BULL" : r == 2 ? "BEAR" : "SIDE"

// Display order: Bull / Bear / Side -> internal code: 1 / 2 / 0
disp_to_internal(d) => d == 0 ? 1 : d == 1 ? 2 : 0

// Regime
log_ret = math.log(close / close[lookback_window])
int regime = na(log_ret) ? na : log_ret > bull_threshold_pct / 100.0 ? 1 : log_ret < -bear_threshold_pct / 100.0 ? 2 : 0

// Ribbon
ribbon_color_for_bar = regime == 1 ? color.rgb(132, 187, 161, 90) : regime == 2 ? color.rgb(197, 127, 134, 90) : color.rgb(164, 171, 183, 90)
bgcolor(show_regime_ribbon ? ribbon_color_for_bar : na, title = "Regime ribbon")

// Transition counting
var counts = array.new_int(9, 0)

prev_regime = regime[1]
if barstate.isconfirmed and not na(prev_regime) and not na(regime)
    idx = prev_regime * 3 + regime
    array.set(counts, idx, array.get(counts, idx) + 1)

// Transition labels
var int last_lbl_regime = na

bool held = not na(regime)
for k = 0 to min_regime_hold - 1
    held := held and not na(regime[k]) and regime[k] == regime

if barstate.isconfirmed and not na(regime) and held and regime != last_lbl_regime
    if show_transition_labels and not na(last_lbl_regime)
        flip_off = min_regime_hold - 1
        label.new(
             bar_index - flip_off,
             high[flip_off],
             regime_abbr(last_lbl_regime) + " -> " + regime_abbr(regime),
             yloc = yloc.abovebar,
             style = label.style_label_down,
             color = regime_solid(regime),
             textcolor = color.white,
             size = size.small
         )
    last_lbl_regime := regime

// Tables
var table tbl_banner     = table.new(banner_pos, 1, 1, bgcolor = c_bg, border_width = 0)
var table tbl_matrix     = table.new(matrix_pos, 4, 5, bgcolor = c_card_bg, border_width = 1, border_color = c_card_bg, frame_color = c_card_frame, frame_width = 1)
var table tbl_stationary = table.new(stationary_pos, 3, 3, bgcolor = c_card_bg, border_width = 1, border_color = c_card_bg, frame_color = c_card_frame, frame_width = 1)

// Matrix multiplication
matmul_3x3(A, B) =>
    a00 = array.get(A, 0)
    a01 = array.get(A, 1)
    a02 = array.get(A, 2)
    a10 = array.get(A, 3)
    a11 = array.get(A, 4)
    a12 = array.get(A, 5)
    a20 = array.get(A, 6)
    a21 = array.get(A, 7)
    a22 = array.get(A, 8)

    b00 = array.get(B, 0)
    b01 = array.get(B, 1)
    b02 = array.get(B, 2)
    b10 = array.get(B, 3)
    b11 = array.get(B, 4)
    b12 = array.get(B, 5)
    b20 = array.get(B, 6)
    b21 = array.get(B, 7)
    b22 = array.get(B, 8)

    C = array.new_float(9, 0.0)
    array.set(C, 0, a00 * b00 + a01 * b10 + a02 * b20)
    array.set(C, 1, a00 * b01 + a01 * b11 + a02 * b21)
    array.set(C, 2, a00 * b02 + a01 * b12 + a02 * b22)
    array.set(C, 3, a10 * b00 + a11 * b10 + a12 * b20)
    array.set(C, 4, a10 * b01 + a11 * b11 + a12 * b21)
    array.set(C, 5, a10 * b02 + a11 * b12 + a12 * b22)
    array.set(C, 6, a20 * b00 + a21 * b10 + a22 * b20)
    array.set(C, 7, a20 * b01 + a21 * b11 + a22 * b21)
    array.set(C, 8, a20 * b02 + a21 * b12 + a22 * b22)
    C

fmt_pct(p) => str.tostring(math.round(p * 100)) + "%"

// Last bar work
if barstate.islast
    P = array.new_float(9, 0.0)
    for r = 0 to 2
        row_sum = array.get(counts, r * 3) + array.get(counts, r * 3 + 1) + array.get(counts, r * 3 + 2)
        for c = 0 to 2
            cell = row_sum > 0 ? array.get(counts, r * 3 + c) / row_sum : 1.0 / 3.0
            array.set(P, r * 3 + c, cell)

    M = array.copy(P)
    for i = 1 to stationary_power - 1
        M := matmul_3x3(M, P)

    stat_bull = array.get(M, 0)
    stat_bear = array.get(M, 1)
    stat_side = array.get(M, 2)

    if show_regime_banner
        table.cell(tbl_banner, 0, 0, "Currently: " + regime_name(regime), text_color = c_text_active, bgcolor = regime_solid(regime), text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)

    if show_matrix_table
        table.cell(tbl_matrix, 0, 0, "QH - TRADERR", text_color = c_accent, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_matrix, 1, 0, "", bgcolor = c_card_bg)
        table.cell(tbl_matrix, 2, 0, "", bgcolor = c_card_bg)
        table.cell(tbl_matrix, 3, 0, "", bgcolor = c_card_bg)

        table.cell(tbl_matrix, 0, 1, "", bgcolor = c_card_bg)
        table.cell(tbl_matrix, 1, 1, "BULL", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_matrix, 2, 1, "BEAR", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_matrix, 3, 1, "SIDE", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)

        for r = 0 to 2
            row_name = r == 0 ? "BULL" : r == 1 ? "BEAR" : "SIDE"
            table.cell(tbl_matrix, 0, r + 2, row_name, text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)

            for c = 0 to 2
                ir = disp_to_internal(r)
                ic = disp_to_internal(c)
                p = array.get(P, ir * 3 + ic)
                is_diag = r == c
                cell_bg = is_diag ? c_diag_bg : c_card_bg
                cell_txt = is_diag ? c_diag_txt : c_off_txt
                cell_sz = is_diag ? val_size : hdr_size
                table.cell(tbl_matrix, c + 1, r + 2, fmt_pct(p), text_color = cell_txt, bgcolor = cell_bg, text_size = cell_sz, text_halign = text.align_center, text_valign = text.align_center)

    if show_stationary_table
        table.cell(tbl_stationary, 0, 0, "LONG-RUN MIX", text_color = c_accent, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_stationary, 1, 0, "", bgcolor = c_card_bg)
        table.cell(tbl_stationary, 2, 0, "", bgcolor = c_card_bg)

        table.cell(tbl_stationary, 0, 1, "BULL", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_stationary, 1, 1, "BEAR", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_stationary, 2, 1, "SIDE", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)

        table.cell(tbl_stationary, 0, 2, fmt_pct(stat_bull), text_color = c_diag_txt, bgcolor = c_diag_bg, text_size = val_size, text_halign = text.align_center, text_valign = text.align_center)
        table.cell(tbl_stationary, 1, 2, fmt_pct(stat_bear), text_color = c_diag_txt, bgcolor = c_diag_bg, text_size = val_size, text_halign = text.align_center, text_valign = text.align_center)
        table.cell(tbl_stationary, 2, 2, fmt_pct(stat_side), text_color = c_diag_txt, bgcolor = c_diag_bg, text_size = val_size, text_halign = text.align_center, text_valign = text.align_center)
````
