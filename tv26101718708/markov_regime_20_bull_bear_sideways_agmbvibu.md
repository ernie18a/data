# Markov Regime 2.0 - Bull / Bear / Sideways

- url: https://www.tradingview.com/script/AgMbVIBU-Markov-Regime-2-0-Bull-Bear-Sideways/
- type: indicator
- pine_id: PUB;c35099057b024ba78f9e17105ff40659
- version: 1.0

## Description

Here's a publish-ready description for the indicator — written to be honest about what it does and doesn't do (in the spirit of the method):

---

**Markov Regime 2.0 — Bull / Bear / Sideways**

A market-regime model that labels price history into Bull / Bear / Sideways states, builds the Markov transition matrix between them, and turns the regime's persistence into a directional signal. This is a corrected rebuild of the classic Markov regime indicator, with three statistical flaws fixed — so the numbers it shows are honest rather than flattering.

**How it works**
- Each bar is labelled by its rolling N-day return: ≥ +5% = Bull, ≤ −5% = Bear, otherwise Sideways (all configurable).
- It counts how often each state transitions to each other state and normalises into a 3×3 probability matrix. The diagonal is the regime "stickiness" — how likely a state is to persist.
- The signal is `P(bull next) − P(bear next)` from today's regime row: sign = direction, magnitude = conviction.

**The three corrections (what makes it 2.0)**
1. **Stride sampling (the autocorrelation fix).** The original counted a transition on *every* bar — but consecutive rolling windows share all but one bar, which manufactures fake persistence on the diagonal. 2.0 also counts transitions between *non-overlapping* windows (stride = lookback). Each matrix cell shows `honest stride % (legacy overlapping % in brackets)` so you can see the inflation directly.
2. **Label self-check.** Before displaying, it verifies that mean return of Bear < Sideways < Bull and flags a `✓`/`✗` next to the sample size — so a mislabelled state can't ship silently.
3. **Explicit signal + modes.** A real signal with a no-edge deadband (Standalone mode sizes a position by conviction; Filter mode just gates longs/shorts), instead of pure visualisation.

**On the chart**
- A compact dashboard: the transition matrix, current regime (TODAY), the live signal with a verdict (`stay flat` / `LONG x%` / `SHORT x%`), sample size and label-check.
- Optional regime ribbon and state-transition labels.
- **Edge markers:** ▲ LONG / ▼ SHORT print on the candle where the *walk-forward* signal first crosses the deadband. The per-bar signal uses only data available up to that bar (no look-ahead), so markers on closed bars don't repaint. Matching alerts are built in.

**How to read it**
Use it on a daily chart — the default is a ~20-*day* regime concept. Treat the honest (stride) column as the real one; if it sits near 33% (a 3-state coin flip) and the signal stays inside the deadband, the model is telling you there's **no edge — stay flat**, and that's a valid answer. The bracketed legacy values are shown only to expose how much the old overlapping method exaggerates persistence. Small-history assets will have a low transition count (`n=`) — the smaller that number, the less you should trust the matrix.

**Disclaimer**
This is a research and visualisation tool, not financial advice and not a strategy with a guaranteed edge. It reads regimes and reports what your own rules imply; it does not place trades. Past regime behaviour does not predict future returns. Always size and manage risk yourself.

Original framework: Roan (@RohOnChain). 2.0 corrections per the Markov 2.0 method.

---

Want a **short version** (2–3 lines for the script's one-liner subtitle), or should I drop this straight into the code as the top comment block / an `//@description` line?

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
// Markov Regime 2.0 — Bull / Bear / Sideways (single-dashboard + edge markers)
// =============================================================================
// Regime model with the three 2.0 corrections + on-chart edge-flip markers.
//   - one transition matrix, cell = honest stride % (legacy overlap % in ())
//   - TODAY row: current regime + window return
//   - SIGNAL row: P(bull)-P(bear) with a NO-EDGE deadband -> "stay flat"
//   - EDGE MARKERS: long/short triangles on the candle where the walk-forward
//     signal first crosses the deadband (no look-ahead; confirmed bars do not
//     repaint).
// FIX 1 stride sampling · FIX 2 label self-check · FIX 3 signal + modes.
// Load on a daily chart (regime is a ~20-DAY concept).
// =============================================================================

indicator("Markov Regime 2.0 - Bull / Bear / Sideways", overlay = true, max_labels_count = 500)

// ── Inputs ──────────────────────────────────────────────────────────────────
grp_logic   = "Regime logic"
grp_signal  = "Signal & mode"
grp_display = "Display"
grp_pos     = "Table positions"

lookback_window    = input.int(20,   "Lookback window (bars)",       minval = 5, maxval = 250, group = grp_logic, tooltip = "Bars for the rolling return AND the stride between non-overlapping samples.")
bull_threshold_pct = input.float(5.0, "Bull threshold (%)",          minval = 0.1, maxval = 50.0, step = 0.1, group = grp_logic)
bear_threshold_pct = input.float(5.0, "Bear threshold (%)",          minval = 0.1, maxval = 50.0, step = 0.1, group = grp_logic)
stationary_power   = input.int(50,   "Stationary power (iterations)",minval = 10, maxval = 200, group = grp_logic)

trade_mode        = input.string("Standalone", "Mode", options = ["Standalone","Filter"], group = grp_signal, tooltip = "Standalone: size scales with |signal|. Filter: signal only gates longs/shorts.")
signal_threshold  = input.float(0.10, "No-edge deadband (|signal|)", minval = 0.0, maxval = 1.0, step = 0.01, group = grp_signal, tooltip = "Below this the signal reads 'stay flat'. Edge markers fire when the signal crosses +/- this.")
max_position_pct  = input.int(100,  "Max position % (Standalone cap)", minval = 1, maxval = 100, group = grp_signal)
show_edge_markers = input.bool(true, "Mark edge flips on candles (long / short)", group = grp_signal)

show_dashboard         = input.bool(true,  "Show dashboard",                group = grp_display)
show_stationary_table  = input.bool(false, "Show stationary distribution",  group = grp_display)
show_regime_ribbon     = input.bool(true,  "Show regime ribbon",            group = grp_display)
show_transition_labels = input.bool(true,  "Label state transitions",       group = grp_display)
table_text_size        = input.string("normal", "Table text size", options = ["small","normal","large","huge"], group = grp_display)
min_regime_hold        = input.int(4, "Min bars a regime must hold to be labelled", minval = 1, maxval = 50, group = grp_display)

dash_position_input       = input.string("top_right",    "Dashboard position",  options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = grp_pos)
stationary_position_input = input.string("bottom_right", "Stationary position", options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = grp_pos)

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

dash_pos       = position_from_string(dash_position_input)
stationary_pos = position_from_string(stationary_position_input)
val_size = size_from_string(table_text_size)
hdr_size = size_from_string(notch_down(table_text_size))

// ── Palette ───────────────────────────────────────────────────────────────
c_card_bg  = color.new(#0B0F0D, 8)
c_frame    = color.new(#3FDE7E, 78)
c_accent   = #3FDE7E
c_diag_bg  = color.new(#3FDE7E, 80)
c_diag_txt = #6BF0A6
c_off_txt  = color.new(color.white, 50)
c_hdr_txt  = color.new(color.white, 35)
c_foot_txt = color.new(color.white, 60)
c_green    = #6BF0A6
c_rose     = #E88E94
c_grayt    = color.new(color.white, 35)

c_bull_solid = color.rgb(132, 187, 161, 30)
c_bear_solid = color.rgb(197, 127, 134, 30)
c_side_solid = color.rgb(164, 171, 183, 30)
regime_solid(r) => r == 1 ? c_bull_solid : r == 2 ? c_bear_solid : c_side_solid
regime_abbr(r)  => r == 1 ? "BULL" : r == 2 ? "BEAR" : "SIDE"
regime_full(r)  => r == 1 ? "BULL" : r == 2 ? "BEAR" : "SIDEWAYS"
regime_txt(r)   => r == 1 ? c_green : r == 2 ? c_rose : c_grayt

d2i(d) => d == 0 ? 2 : d == 1 ? 0 : 1
disp_lbl(d) => d == 0 ? "BEAR" : d == 1 ? "SIDEWAYS" : "BULL"
fmt_pct(p)  => str.tostring(math.round(p * 100)) + "%"
fmt_spct(x) => na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x * 100, "#0.0") + "%"

signal_now(cnt, reg) =>
    float out = na
    if not na(reg)
        rs = array.get(cnt, reg * 3) + array.get(cnt, reg * 3 + 1) + array.get(cnt, reg * 3 + 2)
        if rs > 0
            out := (array.get(cnt, reg * 3 + 1) - array.get(cnt, reg * 3 + 2)) / rs
    out

// ── Per-bar regime ──────────────────────────────────────────────────────────
log_ret = math.log(close / close[lookback_window])
int regime = na
if not na(log_ret)
    regime := log_ret > bull_threshold_pct / 100.0 ? 1 : log_ret < -bear_threshold_pct / 100.0 ? 2 : 0

color ribbon_col = na
if not na(regime)
    ribbon_col := regime == 1 ? color.rgb(132, 187, 161, 90) : regime == 2 ? color.rgb(197, 127, 134, 90) : color.rgb(164, 171, 183, 90)
bgcolor(show_regime_ribbon ? ribbon_col : na, title = "Regime ribbon")

// ── Transition counts: legacy (overlap) + stride (honest) + label buckets ────
var counts_ov = array.new_int(9, 0)
var counts_st = array.new_int(9, 0)
var int stride_counter = 0
var int last_sampled   = na
var float sum_bull = 0.0
var float sum_bear = 0.0
var float sum_side = 0.0
var int n_bull = 0
var int n_bear = 0
var int n_side = 0

if barstate.isconfirmed and not na(regime)
    if not na(regime[1])
        io = regime[1] * 3 + regime
        array.set(counts_ov, io, array.get(counts_ov, io) + 1)
    if regime == 1
        sum_bull := sum_bull + log_ret
        n_bull := n_bull + 1
    else if regime == 2
        sum_bear := sum_bear + log_ret
        n_bear := n_bear + 1
    else
        sum_side := sum_side + log_ret
        n_side := n_side + 1
    stride_counter := stride_counter + 1
    if stride_counter >= lookback_window
        if not na(last_sampled)
            is2 = last_sampled * 3 + regime
            array.set(counts_st, is2, array.get(counts_st, is2) + 1)
        last_sampled := regime
        stride_counter := 0

// ── Walk-forward edge state + flip markers ──────────────────────────────────
edge_sig = signal_now(counts_st, regime)
int edge_state = 0
if not na(edge_sig)
    edge_state := edge_sig >= signal_threshold ? 1 : edge_sig <= -signal_threshold ? -1 : 0
flip_long  = show_edge_markers and barstate.isconfirmed and edge_state == 1  and edge_state[1] != 1
flip_short = show_edge_markers and barstate.isconfirmed and edge_state == -1 and edge_state[1] != -1
plotshape(flip_long,  title = "Edge to Long",  style = shape.triangleup,   location = location.belowbar, color = c_green, textcolor = c_green, text = "LONG",  size = size.tiny)
plotshape(flip_short, title = "Edge to Short", style = shape.triangledown, location = location.abovebar, color = c_rose,  textcolor = c_rose,  text = "SHORT", size = size.tiny)
alertcondition(flip_long,  title = "Markov edge to Long",  message = "Markov 2.0: edge flipped LONG on {{ticker}}")
alertcondition(flip_short, title = "Markov edge to Short", message = "Markov 2.0: edge flipped SHORT on {{ticker}}")

// ── Debounced transition labels ───────────────────────────────────────────
var int last_lbl_regime = na
held = not na(regime)
for k = 0 to min_regime_hold - 1
    held := held and not na(regime[k]) and regime[k] == regime
if barstate.isconfirmed and not na(regime) and held and regime != last_lbl_regime
    if show_transition_labels and not na(last_lbl_regime)
        flip_off = min_regime_hold - 1
        label.new(bar_index - flip_off, high[flip_off], regime_abbr(last_lbl_regime) + "  ->  " + regime_abbr(regime), yloc = yloc.abovebar, style = label.style_label_down, color = regime_solid(regime), textcolor = color.white, size = size.normal)
    last_lbl_regime := regime

// ── Tables ───────────────────────────────────────────────────────────────
var table tbl_dash = table.new(dash_pos, 4, 7, bgcolor = c_card_bg, border_width = 2, border_color = c_card_bg, frame_color = c_frame, frame_width = 1)
var table tbl_stat = table.new(stationary_pos, 3, 4, bgcolor = c_card_bg, border_width = 2, border_color = c_card_bg, frame_color = c_frame, frame_width = 1)

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

normalise(cnt) =>
    P = array.new_float(9, 0.0)
    for r = 0 to 2
        rs = array.get(cnt, r * 3) + array.get(cnt, r * 3 + 1) + array.get(cnt, r * 3 + 2)
        for c = 0 to 2
            array.set(P, r * 3 + c, rs > 0 ? array.get(cnt, r * 3 + c) / rs : 1.0 / 3.0)
    P

if barstate.islast
    P_st = normalise(counts_st)
    P_ov = normalise(counts_ov)
    n_st = array.get(counts_st,0)+array.get(counts_st,1)+array.get(counts_st,2)+array.get(counts_st,3)+array.get(counts_st,4)+array.get(counts_st,5)+array.get(counts_st,6)+array.get(counts_st,7)+array.get(counts_st,8)

    cur   = regime
    sig   = na(cur) ? na : array.get(P_st, cur * 3 + 1) - array.get(P_st, cur * 3 + 2)
    today_ret = close / close[lookback_window] - 1

    absS = na(sig) ? na : math.abs(sig)
    edge = not na(absS) and absS >= signal_threshold
    is_long  = edge and sig > 0
    is_short = edge and sig < 0
    directive = "stay flat"
    if not na(sig)
        if trade_mode == "Standalone"
            sz = math.round(math.min(absS, 1.0) * max_position_pct)
            directive := not edge ? "stay flat" : (is_long ? "LONG " : "SHORT ") + str.tostring(sz) + "%"
        else
            directive := is_long ? "allow longs" : is_short ? "allow shorts" : "stay flat"
    dir_col = is_long ? c_green : is_short ? c_rose : c_off_txt
    edge_tag = edge ? "" : "NO EDGE — "

    m_bull = n_bull > 0 ? sum_bull / n_bull : na
    m_bear = n_bear > 0 ? sum_bear / n_bear : na
    m_side = n_side > 0 ? sum_side / n_side : na
    labels_ok = not na(m_bull) and not na(m_bear) and m_bear < m_bull and (na(m_side) or (m_bear <= m_side and m_side <= m_bull))

    if show_dashboard
        table.cell(tbl_dash, 0, 0, "n=" + str.tostring(n_st) + (labels_ok ? " ✓" : " ✗"), text_color = labels_ok ? c_accent : c_rose, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_dash, 1, 0, "BEAR",     text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 2, 0, "SIDEWAYS", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 3, 0, "BULL",     text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        for r = 0 to 2
            table.cell(tbl_dash, 0, r + 1, disp_lbl(r), text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
            for c = 0 to 2
                ir = d2i(r)
                ic = d2i(c)
                h  = array.get(P_st, ir * 3 + ic)
                l  = array.get(P_ov, ir * 3 + ic)
                is_diag = r == c
                table.cell(tbl_dash, c + 1, r + 1, fmt_pct(h) + " (" + fmt_pct(l) + ")", text_color = is_diag ? c_diag_txt : c_off_txt, bgcolor = is_diag ? c_diag_bg : c_card_bg, text_size = is_diag ? val_size : hdr_size, text_halign = text.align_center, text_valign = text.align_center)
        table.cell(tbl_dash, 0, 4, "TODAY", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_dash, 1, 4, na(cur) ? "n/a" : regime_full(cur), text_color = na(cur) ? c_off_txt : regime_txt(cur), bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 2, 4, fmt_spct(today_ret), text_color = c_off_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 3, 4, str.tostring(lookback_window) + " bars", text_color = c_off_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 0, 5, "SIGNAL", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_dash, 1, 5, "bull−bear", text_color = c_foot_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 2, 5, fmt_spct(sig), text_color = c_accent, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 3, 5, edge_tag + directive, text_color = dir_col, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 0, 6, "honest stride %", text_color = c_foot_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_dash, 1, 6, "(legacy", text_color = c_foot_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_right)
        table.cell(tbl_dash, 2, 6, "overlapping %", text_color = c_foot_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_dash, 3, 6, "in brackets)", text_color = c_foot_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)

    if show_stationary_table
        M = array.copy(P_st)
        for _i = 1 to stationary_power - 1
            M := matmul_3x3(M, P_st)
        table.cell(tbl_stat, 0, 0, "LONG-RUN MIX", text_color = c_accent, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_stat, 1, 0, "", bgcolor = c_card_bg)
        table.cell(tbl_stat, 2, 0, "", bgcolor = c_card_bg)
        table.cell(tbl_stat, 0, 1, "BEAR",     text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_stat, 1, 1, "SIDEWAYS", text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_stat, 2, 1, "BULL",     text_color = c_hdr_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_center)
        table.cell(tbl_stat, 0, 2, fmt_pct(array.get(M,2)), text_color = c_diag_txt, bgcolor = c_diag_bg, text_size = val_size, text_halign = text.align_center)
        table.cell(tbl_stat, 1, 2, fmt_pct(array.get(M,0)), text_color = c_diag_txt, bgcolor = c_diag_bg, text_size = val_size, text_halign = text.align_center)
        table.cell(tbl_stat, 2, 2, fmt_pct(array.get(M,1)), text_color = c_diag_txt, bgcolor = c_diag_bg, text_size = val_size, text_halign = text.align_center)
        table.cell(tbl_stat, 0, 3, "no edge at horizon", text_color = c_foot_txt, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_left)
        table.cell(tbl_stat, 1, 3, "", bgcolor = c_card_bg)
        table.cell(tbl_stat, 2, 3, "steady", text_color = c_accent, bgcolor = c_card_bg, text_size = hdr_size, text_halign = text.align_right)

// =============================================================================
````
