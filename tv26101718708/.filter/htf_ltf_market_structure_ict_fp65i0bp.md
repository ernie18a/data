# HTF + LTF Market Structure ICT

- url: https://www.tradingview.com/script/fP65I0Bp-HTF-LTF-Market-Structure-ICT/
- type: indicator
- pine_id: PUB;bb077fb2753b4609a61a7c1e9481f8ce
- version: 1.0

## Description

HTF + LTF Market Structure ICT
A dual-stream ICT-style market structure tool that detects MSS (Change of Character) and BOS (Break of Structure) events on both a higher timeframe and the current chart timeframe simultaneously — so you can read HTF context and LTF structure on a single chart.

What it does
The indicator runs the same fractal-based structure detector twice in parallel:

HTF stream (default M15) — runs via request.security with lookahead_off, so events are confirmed at the HTF candle close. Each event renders as a small labeled ribbon tag (e.g. M15 CHoCH ↑) on the LTF bar where the HTF candle closed. Bull tags sit below the bar, bear tags above. No projected lines.
LTF stream — runs on the chart TF directly. Each event renders as a break-level line spanning the broken fractal pivot to the firing bar, plus a minimal CHoCH / BOS text label at the line's midpoint — colored text only, no background fill. Bull text floats above the line, bear below.
Each stream tracks its own trend state, so the HTF and LTF can disagree — that disagreement is the actionable read (e.g. HTF still bullish while LTF just printed a CHoCH down = first sign of a pullback against trend).

How structure is classified
Each stream maintains its own directional bias:

MSS / CHoCH — the first break against the prior structural trend (reversal signal).
BOS — a break in the same direction as the current trend (continuation).
The very first event of each stream is classified as MSS by default since there's no prior reference. Line style differs: solid for MSS, dashed for BOS by default.

Detection logic
A fractal swing pivot is confirmed when a high/low is the extreme over a configurable length (default 5).
A break fires when the bar's close crosses through the most recent unbroken fractal (above for bull, below for bear), with barstate.isconfirmed so events don't repaint.
Auto-suppression
When the chart timeframe equals the chosen HTF (e.g. you're viewing the M15 chart with HTF = M15), the HTF ribbon is hidden — both streams would otherwise detect the exact same events on the same bars.

Inputs
HTF stream — HTF (15min / 30min / 1H / 4H / 1D), fractal length, MSS / BOS toggles
LTF stream — fractal length, MSS / BOS toggles
Display — line on/off, forward-extend latest line, LTF text on/off, history depth
Style — line styles (MSS solid / BOS dashed), line width, HTF ribbon size + transparency, LTF text size, bull / bear colors

Alerts
Ten preconfigured alertconditions:

HTF Bull CHoCH / Bear CHoCH / Bull BOS / Bear BOS
LTF Bull CHoCH / Bear CHoCH / Bull BOS / Bear BOS
LTF bull aligned with HTF-bull bias (confluence)
LTF bear aligned with HTF-bear bias (confluence)
Suggested use
Works on any symbol or timeframe. Default M15 HTF on an M1 / M3 / M5 chart gives a clean intraday read; for swing structure, try chart TF = 1H with HTF = 4H or 1D. The fractal length controls signal density — drop to 3 for more frequent events on lower-volatility instruments, raise to 7+ to filter for stronger swings.

This is a structure visualization tool, not a trading system — it doesn't take trades, manage risk, or compute lot sizes. Use it to read HTF context and LTF trigger timing.

Disclaimer
This script is for educational and analytical purposes only. It does not provide financial advice and does not guarantee profitability. Past performance of any structural pattern does not imply future results. Always combine with your own analysis and risk management.

Quick adjustments you might want before publishing: short title for TV (e.g. HTF+LTF MSS ICT), and grab a chart screenshot showing both HTF ribbons and LTF text active.

## Source Code

````pine
//@version=5
// HTF + LTF Market Structure ICT
// Dual-stream ICT market structure on one chart:
//   • HTF stream — labeled ribbon (e.g. "M15 CHoCH ↑") at the LTF bar
//     where the HTF candle closes with an MSS/BOS. No projected line.
//   • LTF stream — break-level line spanning the broken fractal →
//     firing bar, plus a minimal "CHoCH" / "BOS" text label at the
//     line's midpoint — colored text only, no background fill.
//     Bull text sits above the line, bear below.
//
// Each stream tracks its own trend state, so the streams can disagree —
// HTF-bull + LTF-CHoCH-up = the actionable confluence ICT traders watch
// for. No trade execution here; this is the structure visualization layer.
//
// Naming:
//   MSS / CHoCH = first break against the prior trend (reversal)
//   BOS         = break in the same direction as the current trend
//                 (continuation)
//
// Detection mirrors syouske_mss_v2.pine: fractal pivots (configurable
// length), close-through-level break. The HTF stream runs via
// request.security, the LTF stream runs locally on the chart TF.

indicator("HTF + LTF Market Structure ICT", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Inputs                                                                                                ---+//
//+------------------------------------------------------------------------------------------------------------+//
htf_choice      = input.string("15min", "HTF", options=["15min","30min","1H","4H","1D"], group='HTF stream')
htf_tf = switch htf_choice
    "15min" => "15"
    "30min" => "30"
    "1H"    => "60"
    "4H"    => "240"
    =>         "D"
htf_tag = switch htf_choice
    "15min" => "M15"
    "30min" => "M30"
    "1H"    => "H1"
    "4H"    => "H4"
    =>         "D"
htf_ms_length   = input.int(5, "HTF fractal length", minval=3, group='HTF stream')
htf_show_mss    = input.bool(true,  "Show HTF MSS / CHoCH ribbon", group='HTF stream')
htf_show_bos    = input.bool(true,  "Show HTF BOS ribbon", group='HTF stream')

ltf_ms_length   = input.int(5, "LTF fractal length", minval=3, group='LTF stream')
ltf_show_mss    = input.bool(true,  "Show LTF MSS / CHoCH", group='LTF stream')
ltf_show_bos    = input.bool(true,  "Show LTF BOS", group='LTF stream')

show_line       = input.bool(true,  "Draw LTF break level lines", group='Display')
extend_latest   = input.bool(false, "Extend latest LTF line forward", group='Display', tooltip="Keeps the most recent LTF break line extending right until a newer LTF event replaces it.")
show_ltf_label  = input.bool(true,  "Show LTF text on line", group='Display', tooltip="Minimal colored text at the line midpoint — no background fill. Bull text sits above the line, bear below.")
keep_n          = input.int(999, "Keep last N events per stream", minval=1, group='Display')

mss_style_in    = input.string("solid",  "MSS / CHoCH line style", options=["solid","dashed","dotted"], group='Style')
bos_style_in    = input.string("dashed", "BOS line style",          options=["solid","dashed","dotted"], group='Style')
ltf_width       = input.int(1, "LTF line width", minval=1, maxval=4, group='Style')
htf_lbl_size_in = input.string("Small", "HTF ribbon size", options=["Tiny","Small","Normal","Large"], group='Style')
htf_lbl_opa     = input.int(20, "HTF ribbon transparency (0–100)", minval=0, maxval=100, group='Style')
ltf_lbl_size_in = input.string("Tiny", "LTF text size", options=["Tiny","Small","Normal","Large"], group='Style')
bullCss         = input.color(#089981, "Bull color", group='Style')
bearCss         = input.color(#f23645, "Bear color", group='Style')

mss_style = mss_style_in == "solid" ? line.style_solid : mss_style_in == "dotted" ? line.style_dotted : line.style_dashed
bos_style = bos_style_in == "solid" ? line.style_solid : bos_style_in == "dotted" ? line.style_dotted : line.style_dashed
htf_lbl_size = htf_lbl_size_in == "Tiny" ? size.tiny : htf_lbl_size_in == "Small" ? size.small : htf_lbl_size_in == "Large" ? size.large : size.normal
ltf_lbl_size = ltf_lbl_size_in == "Tiny" ? size.tiny : ltf_lbl_size_in == "Small" ? size.small : ltf_lbl_size_in == "Large" ? size.large : size.normal

// Friendly LTF (chart TF) tag — used in event labels.
ltf_secs = timeframe.in_seconds()
ltf_tag = switch ltf_secs
    60    => "M1"
    180   => "M3"
    300   => "M5"
    900   => "M15"
    1800  => "M30"
    3600  => "H1"
    14400 => "H4"
    86400 => "D"
    =>       timeframe.period

//+------------------------------------------------------------------------------------------------------------+//
//+--- MSS detection (shared by both streams)                                                               ---+//
//+------------------------------------------------------------------------------------------------------------+//
// `var` state inside the function is scoped per call-site — the HTF
// call (via request.security) and the LTF call (local) each keep
// independent state, so they don't collide.

mss_detect(simple int ms_len) =>
    var float upper_val      = na
    var int   upper_loc_time = na
    var bool  upper_crossed  = true
    var float lower_val      = na
    var int   lower_loc_time = na
    var bool  lower_crossed  = true

    p     = int(ms_len / 2)
    dh    = math.sum(math.sign(high - high[1]), p)
    dl    = math.sum(math.sign(low  - low[1] ), p)
    bullf = dh == -p and dh[p] ==  p and high[p] == ta.highest(ms_len)
    bearf = dl ==  p and dl[p] == -p and low[p]  == ta.lowest(ms_len)

    if bullf
        upper_val      := high[p]
        upper_loc_time := time[p]
        upper_crossed  := false
    if bearf
        lower_val      := low[p]
        lower_loc_time := time[p]
        lower_crossed  := false

    bool  bull_fired = false
    bool  bear_fired = false
    float bull_lvl   = na
    int   bull_t     = na
    float bear_lvl   = na
    int   bear_t     = na

    if not upper_crossed and not na(upper_val) and close > upper_val and close[1] <= upper_val and barstate.isconfirmed
        bull_fired := true
        bull_lvl   := upper_val
        bull_t     := upper_loc_time
        upper_crossed := true

    if not lower_crossed and not na(lower_val) and close < lower_val and close[1] >= lower_val and barstate.isconfirmed
        bear_fired := true
        bear_lvl   := lower_val
        bear_t     := lower_loc_time
        lower_crossed := true

    [bull_fired, bear_fired, bull_lvl, bull_t, bear_lvl, bear_t]

//+------------------------------------------------------------------------------------------------------------+//
//+--- HTF + LTF streams                                                                                    ---+//
//+------------------------------------------------------------------------------------------------------------+//
[htf_bull_raw, htf_bear_raw, htf_bull_lvl, htf_bull_t, htf_bear_lvl, htf_bear_t] = request.security(syminfo.tickerid, htf_tf, mss_detect(htf_ms_length), lookahead=barmerge.lookahead_off)
[ltf_bull,     ltf_bear,     ltf_bull_lvl, ltf_bull_t, ltf_bear_lvl, ltf_bear_t] = mss_detect(ltf_ms_length)

// Edge-detect HTF fires. With lookahead_off the boolean stays true for
// the entire next HTF bar (i.e. for every LTF bar inside it); rising
// edge gives us the single LTF bar where we first see the break.
htf_bull_arm = htf_bull_raw and not htf_bull_raw[1]
htf_bear_arm = htf_bear_raw and not htf_bear_raw[1]
// LTF mss_detect already fires once on the bar where the break confirms.
ltf_bull_arm = ltf_bull
ltf_bear_arm = ltf_bear

//+------------------------------------------------------------------------------------------------------------+//
//+--- MSS vs BOS classification (per-stream trend state)                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//
var int htf_trend = 0
var int ltf_trend = 0

htf_is_bull_mss = htf_bull_arm and htf_trend !=  1
htf_is_bull_bos = htf_bull_arm and htf_trend ==  1
htf_is_bear_mss = htf_bear_arm and htf_trend != -1
htf_is_bear_bos = htf_bear_arm and htf_trend == -1
if htf_bull_arm
    htf_trend := 1
if htf_bear_arm
    htf_trend := -1

ltf_is_bull_mss = ltf_bull_arm and ltf_trend !=  1
ltf_is_bull_bos = ltf_bull_arm and ltf_trend ==  1
ltf_is_bear_mss = ltf_bear_arm and ltf_trend != -1
ltf_is_bear_bos = ltf_bear_arm and ltf_trend == -1
if ltf_bull_arm
    ltf_trend := 1
if ltf_bear_arm
    ltf_trend := -1

//+------------------------------------------------------------------------------------------------------------+//
//+--- Drawing                                                                                              ---+//
//+------------------------------------------------------------------------------------------------------------+//
// HTF → labeled "ribbon" tag at firing bar, no projected line.
// LTF → break-level line spanning fractal → firing bar, no label.
n = bar_index

var line[]  ltf_lines  = array.new<line>()
var label[] ltf_labels = array.new<label>()
var label[] htf_labels = array.new<label>()
var line    ltf_latest = na

prune_lines(line[] arr) =>
    while arr.size() > keep_n
        old = arr.shift()
        if not na(old)
            line.delete(old)
prune_labels(label[] arr) =>
    while arr.size() > keep_n
        old = arr.shift()
        if not na(old)
            label.delete(old)

// HTF ribbon — labeled tag at the LTF bar where the HTF candle closes
// with an MSS/BOS. Bull labels sit below the bar, bear above.
draw_htf_ribbon(bool is_bull, bool is_mss) =>
    show_it = (is_mss and htf_show_mss) or (not is_mss and htf_show_bos)
    label out = na
    if show_it
        col      = is_bull ? bullCss : bearCss
        arrow    = is_bull ? "↑" : "↓"
        kind     = is_mss ? "CHoCH" : "BOS"
        txt      = htf_tag + " " + kind + " " + arrow
        sty_lbl  = is_bull ? label.style_label_up : label.style_label_down
        yloc_lbl = is_bull ? yloc.belowbar : yloc.abovebar
        y_anchor = is_bull ? low : high
        out := label.new(bar_index, y_anchor, txt, xloc=xloc.bar_index, style=sty_lbl, color=color.new(col, htf_lbl_opa), textcolor=color.white, size=htf_lbl_size, yloc=yloc_lbl)
    out

// When the chart TF equals the HTF, the HTF stream detects the exact
// same events as the LTF stream — drawing both would be redundant, so
// suppress the HTF ribbon in that case.
htf_visible = htf_tf != timeframe.period

if htf_bull_arm and htf_visible
    lb_h = draw_htf_ribbon(true, htf_is_bull_mss)
    if not na(lb_h)
        htf_labels.push(lb_h)
        prune_labels(htf_labels)
if htf_bear_arm and htf_visible
    lb_h2 = draw_htf_ribbon(false, htf_is_bear_mss)
    if not na(lb_h2)
        htf_labels.push(lb_h2)
        prune_labels(htf_labels)

// LTF line — break-level line from broken fractal → firing bar.
draw_ltf_line(bool is_bull, bool is_mss, float lvl, int t_anchor) =>
    show_it = show_line and ((is_mss and ltf_show_mss) or (not is_mss and ltf_show_bos)) and not na(lvl) and not na(t_anchor)
    line out = na
    if show_it
        col = is_bull ? bullCss : bearCss
        sty = is_mss ? mss_style : bos_style
        out := line.new(t_anchor, lvl, time, lvl, xloc=xloc.bar_time, color=col, width=ltf_width, style=sty)
    out

// LTF text — minimal "CHoCH" / "BOS" text at the midpoint of the
// broken-level line. No label background, no pointer — just colored
// text. style_label_down positions text above the anchor (bull case);
// style_label_up positions it below (bear case). The label fill is
// transparent so only the text glyphs render.
draw_ltf_label(bool is_bull, bool is_mss, float lvl, int t_anchor) =>
    show_it = show_ltf_label and ((is_mss and ltf_show_mss) or (not is_mss and ltf_show_bos)) and not na(lvl) and not na(t_anchor)
    label out = na
    if show_it
        col      = is_bull ? bullCss : bearCss
        kind     = is_mss ? "CHoCH" : "BOS"
        sty_lbl  = is_bull ? label.style_label_down : label.style_label_up
        mid_time = int(math.avg(t_anchor, time))
        out := label.new(mid_time, lvl, kind, xloc=xloc.bar_time, yloc=yloc.price, style=sty_lbl, color=color(na), textcolor=col, size=ltf_lbl_size)
    out

if ltf_bull_arm
    ln_l = draw_ltf_line(true, ltf_is_bull_mss, ltf_bull_lvl, ltf_bull_t)
    if not na(ln_l)
        ltf_lines.push(ln_l)
        ltf_latest := ln_l
        prune_lines(ltf_lines)
    lb_ltf = draw_ltf_label(true, ltf_is_bull_mss, ltf_bull_lvl, ltf_bull_t)
    if not na(lb_ltf)
        ltf_labels.push(lb_ltf)
        prune_labels(ltf_labels)
if ltf_bear_arm
    ln_l2 = draw_ltf_line(false, ltf_is_bear_mss, ltf_bear_lvl, ltf_bear_t)
    if not na(ln_l2)
        ltf_lines.push(ln_l2)
        ltf_latest := ln_l2
        prune_lines(ltf_lines)
    lb_ltf2 = draw_ltf_label(false, ltf_is_bear_mss, ltf_bear_lvl, ltf_bear_t)
    if not na(lb_ltf2)
        ltf_labels.push(lb_ltf2)
        prune_labels(ltf_labels)

if extend_latest and not na(ltf_latest)
    line.set_x2(ltf_latest, time)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Alerts                                                                                               ---+//
//+------------------------------------------------------------------------------------------------------------+//
alertcondition(htf_is_bull_mss, title="HTF Bull CHoCH", message="HTF Bull MSS / CHoCH — potential bullish reversal")
alertcondition(htf_is_bear_mss, title="HTF Bear CHoCH", message="HTF Bear MSS / CHoCH — potential bearish reversal")
alertcondition(htf_is_bull_bos, title="HTF Bull BOS",   message="HTF Bull BOS — bullish continuation")
alertcondition(htf_is_bear_bos, title="HTF Bear BOS",   message="HTF Bear BOS — bearish continuation")
alertcondition(ltf_is_bull_mss, title="LTF Bull CHoCH", message="LTF Bull MSS / CHoCH — potential bullish reversal")
alertcondition(ltf_is_bear_mss, title="LTF Bear CHoCH", message="LTF Bear MSS / CHoCH — potential bearish reversal")
alertcondition(ltf_is_bull_bos, title="LTF Bull BOS",   message="LTF Bull BOS — bullish continuation")
alertcondition(ltf_is_bear_bos, title="LTF Bear BOS",   message="LTF Bear BOS — bearish continuation")
// Confluence alerts — HTF and LTF agree direction on an LTF event.
alertcondition(ltf_bull_arm and htf_trend ==  1, title="LTF bull in HTF-bull bias", message="LTF bullish structure event aligned with HTF-bull bias")
alertcondition(ltf_bear_arm and htf_trend == -1, title="LTF bear in HTF-bear bias", message="LTF bearish structure event aligned with HTF-bear bias")
````
