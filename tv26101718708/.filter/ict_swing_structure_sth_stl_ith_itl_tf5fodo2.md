# ICT Swing Structure (STH - STL - ITH - ITL)

- url: https://www.tradingview.com/script/Tf5fodO2-ICT-Swing-Structure-STH-STL-ITH-ITL/
- type: indicator
- pine_id: PUB;74ed145b071c4ef0b6705e8ca0381ffb
- version: 1.0

## Description

This indicator identifies ICT Swing Structure using a custom swing engine designed to follow ICT market structure concepts rather than traditional pivot calculations.

Unlike standard pivot-based indicators, this script is built to correctly process market structure by accounting for inside candles and delayed swing confirmation, resulting in cleaner and more consistent swing identification.

Features
Identifies Short-Term Highs (STH)
Identifies Short-Term Lows (STL)
Identifies Intermediate-Term Highs (ITH)
Identifies Intermediate-Term Lows (ITL)
Custom swing detection engine (not based on TradingView pivot functions)
Handles consecutive inside candles
Supports configurable equal high/equal low behavior
Non-repainting after swing confirmation
Lightweight and optimized for performance
Swing Hierarchy

The indicator follows ICT's swing hierarchy:

STH/STL represent confirmed short-term swings.
ITH/ITL are derived exclusively from confirmed short-term swings, creating a true hierarchical market structure rather than calculating every level directly from price.

This approach produces a cleaner representation of market structure and liquidity than conventional pivot indicators.

Designed For

This indicator is intended for traders who use ICT or Smart Money Concepts, including:

Liquidity analysis
Market structure
Premium & Discount arrays
Order Blocks
Fair Value Gaps (FVG)
Market Structure Shift (MSS)
Break of Structure (BOS)

The indicator focuses solely on identifying swing structure, making it an excellent foundation for traders who prefer to perform the rest of their analysis manually.

Notes
Swings are confirmed only after sufficient price action confirms the structure.
Once confirmed, swings do not repaint or relocate.
Labels are plotted on the actual swing candle after confirmation occurs.

This indicator is designed to provide an objective and consistent view of ICT swing structure while remaining faithful to the concepts taught by ICT.

## Source Code

````pine
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                        ICT Swing Structure [v6]                            ║
// ║                                                                            ║
// ║  Identifies Short-Term Highs/Lows (STH/STL) and Intermediate-Term          ║
// ║  Highs/Lows (ITH/ITL) using a dual state-machine approach.                 ║
// ║                                                                            ║
// ║  • No ta.pivothigh / ta.pivotlow — pure price-action logic.                ║
// ║  • Inside candles are gated out; the reference bar stays fixed until        ║
// ║    a candle breaks the reference range.                                    ║
// ║  • Labels are placed at the actual swing bar, never at the confirmation    ║
// ║    bar.                                                                    ║
// ║  • Multi-timeframe: structure is detected on the selected HTF while        ║
// ║    labels are placed accurately on any lower chart timeframe.              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
//@version=6
indicator("ICT Swing Structure [v6]", shorttitle="ICT Swing", overlay=true, max_labels_count=500)

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                                 INPUTS                                     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

show_sth = input.bool(true, "Show STH", group="Visibility", inline="row1")
show_ith = input.bool(true, "Show ITH", group="Visibility", inline="row1")
show_stl = input.bool(true, "Show STL", group="Visibility", inline="row2")
show_itl = input.bool(true, "Show ITL", group="Visibility", inline="row2")

col_sth = input.color(color.yellow, "STH Color", group="Colors", inline="c1")
col_ith = input.color(color.red,    "ITH Color", group="Colors", inline="c1")
col_stl = input.color(color.aqua,   "STL Color", group="Colors", inline="c2")
col_itl = input.color(color.lime,   "ITL Color", group="Colors", inline="c2")

use_chart_tf = input.bool(false, "Use Chart Timeframe", group="Settings",
     tooltip="When enabled, swing structure is detected on the current chart timeframe " +
             "and the Structure Timeframe dropdown below is ignored.")
tf           = input.timeframe("240", "Structure Timeframe", group="Settings",
     tooltip="Timeframe for swing detection. E.g. '240' = 4H. " +
             "Ignored when 'Use Chart Timeframe' is enabled above.")
lbl_size_str = input.string("small", "Label Size", options=["tiny","small","normal","large","huge"], group="Settings")
max_lbl_cnt  = input.int(200, "Max Labels", minval=10, maxval=500, group="Settings")
eq_highs     = input.bool(true, "Allow Equal Highs", group="Settings")
eq_lows      = input.bool(true, "Allow Equal Lows",  group="Settings")

debug_mode = input.bool(false, "Debug Mode", group="Debug",
     tooltip="Enables visual overlays for the internal state of both state machines.")

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                          USER-DEFINED TYPE                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

type SwingState
    float ref_high   = na
    float ref_low    = na
    int   ref_bar    = -1
    float cand_price = na
    int   cand_time  = -1    // HTF bar open-time (ms) — used with xloc.bar_time
    bool  has_cand   = false

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                        PERSISTENT INSTANCES                                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

var SwingState h_sm = SwingState.new()
var SwingState l_sm = SwingState.new()

var array<float> sth_prices = array.new<float>()
var array<int>   sth_times  = array.new<int>()   // HTF open-time of each confirmed STH
var array<float> stl_prices = array.new<float>()
var array<int>   stl_times  = array.new<int>()   // HTF open-time of each confirmed STL

var array<int>   ith_labeled = array.new<int>()
var array<int>   itl_labeled = array.new<int>()
var array<label> label_pool  = array.new<label>()

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                         PURE HELPER FUNCTIONS                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

f_size() =>
    switch lbl_size_str
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

// Uses xloc.bar_time so labels snap to the correct candle on ANY chart timeframe.
f_create_label(int bar_t, float price, string txt, color lbl_col, string lbl_style, string yloc_type) =>
    lbl = label.new(x         = bar_t,
                    y         = price,
                    text      = txt,
                    color     = lbl_col,
                    textcolor = color.black,
                    style     = lbl_style,
                    xloc      = xloc.bar_time,
                    yloc      = yloc_type,
                    size      = f_size())
    array.push(label_pool, lbl)
    while array.size(label_pool) > max_lbl_cnt
        label.delete(array.shift(label_pool))

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                     HIGH-SIDE STATE MACHINE METHOD                         ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// @returns [confirmed, conf_price, conf_time]
method process_high(SwingState this, float curr_h, float curr_l, int curr_time, bool allow_equal) =>
    confirmed  = false
    conf_price = float(na)
    conf_time  = int(na)

    if na(this.ref_high)
        this.ref_high := curr_h
        this.ref_low  := curr_l
        this.ref_bar  := bar_index
    else
        curr_inside = curr_h <= this.ref_high and curr_l >= this.ref_low

        if not curr_inside
            if this.has_cand
                is_higher = allow_equal ? curr_h >= this.cand_price : curr_h > this.cand_price
                if is_higher
                    this.cand_price := curr_h
                    this.cand_time  := curr_time
                else
                    confirmed  := true
                    conf_price := this.cand_price
                    conf_time  := this.cand_time
                    this.has_cand   := false
                    this.cand_price := float(na)
                    this.cand_time  := int(na)
            else
                is_higher = allow_equal ? curr_h >= this.ref_high : curr_h > this.ref_high
                if is_higher
                    this.cand_price := curr_h
                    this.cand_time  := curr_time
                    this.has_cand   := true

            this.ref_high := curr_h
            this.ref_low  := curr_l
            this.ref_bar  := bar_index

    [confirmed, conf_price, conf_time]

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                      LOW-SIDE STATE MACHINE METHOD                         ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// @returns [confirmed, conf_price, conf_time]
method process_low(SwingState this, float curr_h, float curr_l, int curr_time, bool allow_equal) =>
    confirmed  = false
    conf_price = float(na)
    conf_time  = int(na)

    if na(this.ref_low)
        this.ref_high := curr_h
        this.ref_low  := curr_l
        this.ref_bar  := bar_index
    else
        curr_inside = curr_h <= this.ref_high and curr_l >= this.ref_low

        if not curr_inside
            if this.has_cand
                is_lower = allow_equal ? curr_l <= this.cand_price : curr_l < this.cand_price
                if is_lower
                    this.cand_price := curr_l
                    this.cand_time  := curr_time
                else
                    confirmed  := true
                    conf_price := this.cand_price
                    conf_time  := this.cand_time
                    this.has_cand   := false
                    this.cand_price := float(na)
                    this.cand_time  := int(na)
            else
                is_lower = allow_equal ? curr_l <= this.ref_low : curr_l < this.ref_low
                if is_lower
                    this.cand_price := curr_l
                    this.cand_time  := curr_time
                    this.has_cand   := true

            this.ref_high := curr_h
            this.ref_low  := curr_l
            this.ref_bar  := bar_index

    [confirmed, conf_price, conf_time]

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                        ITH / ITL DETECTION                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// @returns [found, price, time]
f_check_ith() =>
    found   = false
    ret_px  = float(na)
    ret_t   = int(na)
    n = array.size(sth_prices)
    if n >= 3
        p_left  = array.get(sth_prices, n - 3)
        p_mid   = array.get(sth_prices, n - 2)
        p_right = array.get(sth_prices, n - 1)
        t_mid   = array.get(sth_times,  n - 2)
        if p_mid > p_left and p_mid > p_right
            found  := true
            ret_px := p_mid
            ret_t  := t_mid
    [found, ret_px, ret_t]

// @returns [found, price, time]
f_check_itl() =>
    found   = false
    ret_px  = float(na)
    ret_t   = int(na)
    n = array.size(stl_prices)
    if n >= 3
        p_left  = array.get(stl_prices, n - 3)
        p_mid   = array.get(stl_prices, n - 2)
        p_right = array.get(stl_prices, n - 1)
        t_mid   = array.get(stl_times,  n - 2)
        if p_mid < p_left and p_mid < p_right
            found  := true
            ret_px := p_mid
            ret_t  := t_mid
    [found, ret_px, ret_t]

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                          MAIN EXECUTION LOOP                               ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

// Step 1: Resolve active timeframe — chart TF overrides the dropdown when checked
active_tf = use_chart_tf ? timeframe.period : tf

// Fetch OHLC + open-time on the active timeframe
htf_high = request.security(syminfo.tickerid, active_tf, high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htf_low  = request.security(syminfo.tickerid, active_tf, low,  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htf_time = request.security(syminfo.tickerid, active_tf, time, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Step 2: Capture inside-candle state BEFORE state machines update (for debug)
h_inside_pre = not na(h_sm.ref_high) and htf_high <= h_sm.ref_high and htf_low >= h_sm.ref_low
l_inside_pre = not na(l_sm.ref_low)  and htf_high <= l_sm.ref_high and htf_low >= l_sm.ref_low

// Step 3: Run both state machines on HTF data
[sth_conf, sth_px, sth_tx] = h_sm.process_high(htf_high, htf_low, htf_time, eq_highs)
[stl_conf, stl_px, stl_tx] = l_sm.process_low(htf_high,  htf_low, htf_time, eq_lows)

// Step 4: Handle confirmed STH
if sth_conf
    array.push(sth_prices, sth_px)
    array.push(sth_times,  sth_tx)
    if show_sth
        f_create_label(sth_tx, sth_px, "STH", col_sth, label.style_label_down, yloc.price)
    [ith_c, ith_px, ith_tx] = f_check_ith()
    if ith_c and show_ith
        if not array.includes(ith_labeled, ith_tx)
            array.push(ith_labeled, ith_tx)
            f_create_label(ith_tx, ith_px, "ITH", col_ith, label.style_label_down, yloc.price)

// Step 5: Handle confirmed STL
if stl_conf
    array.push(stl_prices, stl_px)
    array.push(stl_times,  stl_tx)
    if show_stl
        f_create_label(stl_tx, stl_px, "STL", col_stl, label.style_label_up, yloc.price)
    [itl_c, itl_px, itl_tx] = f_check_itl()
    if itl_c and show_itl
        if not array.includes(itl_labeled, itl_tx)
            array.push(itl_labeled, itl_tx)
            f_create_label(itl_tx, itl_px, "ITL", col_itl, label.style_label_up, yloc.price)

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                            DEBUG OVERLAY                                   ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

plot(debug_mode and h_sm.has_cand ? h_sm.cand_price : na,
     title="[DBG] H Candidate", color=color.new(color.orange, 0),
     linewidth=2, style=plot.style_circles)

plot(debug_mode and l_sm.has_cand ? l_sm.cand_price : na,
     title="[DBG] L Candidate", color=color.new(color.purple, 0),
     linewidth=2, style=plot.style_circles)

plot(debug_mode ? h_sm.ref_high : na,
     title="[DBG] H Ref High", color=color.new(color.orange, 65),
     linewidth=1, style=plot.style_stepline)

plot(debug_mode ? l_sm.ref_low : na,
     title="[DBG] L Ref Low", color=color.new(color.purple, 65),
     linewidth=1, style=plot.style_stepline)

plotshape(debug_mode and h_sm.has_cand,
          title="[DBG] H Candidate Active", style=shape.triangledown,
          location=location.abovebar, color=color.new(color.orange, 25), size=size.tiny)

plotshape(debug_mode and l_sm.has_cand,
          title="[DBG] L Candidate Active", style=shape.triangleup,
          location=location.belowbar, color=color.new(color.purple, 25), size=size.tiny)

plotshape(debug_mode and h_inside_pre,
          title="[DBG] H Inside Candle", style=shape.circle,
          location=location.abovebar, color=color.new(color.gray, 45), size=size.tiny)

plotshape(debug_mode and l_inside_pre,
          title="[DBG] L Inside Candle", style=shape.circle,
          location=location.belowbar, color=color.new(color.gray, 45), size=size.tiny)

bgcolor(debug_mode and h_inside_pre and l_inside_pre
        ? color.new(color.gray, 88) : na,
        title="[DBG] Full Inside Bar Background")

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                              END OF SCRIPT                                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
````
