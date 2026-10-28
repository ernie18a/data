# Ripster EMA Cloud Alerts  MTF Confirmed v6

- url: https://www.tradingview.com/script/Yf2M4JOt-Ripster-EMA-Cloud-Alerts-MTF-Confirmed-v6/
- type: indicator
- pine_id: PUB;d203e553f70248d6bb387a68d53890eb
- version: 1.0

## Description

Using the Repster methodology to screen for Bullish stocks.

## Source Code

````pine
//@version=6
indicator("Ripster EMA Cloud Alerts — MTF Confirmed v6", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  RIPSTER EMA CLOUD ALERTS — MULTI-TIMEFRAME CONFIRMED v6
//  Run on your entry timeframe (e.g. 15 min)
//  Pulls 1H and Daily cloud data to filter signals
//
//  ✅ Green label  = confirmed bullish across all timeframes
//  🟠 Orange label = partial / mixed signal (caution)
//  ❌ No label     = higher TF disagrees — filtered out
// ═══════════════════════════════════════════════════════════════

// ── TIMEFRAME INPUTS ────────────────────────────────────────────
string tf_mid  = input.timeframe("60", "Mid Timeframe (default 1H)",     group="⏱️ Higher Timeframes")
string tf_high = input.timeframe("D",  "High Timeframe (default Daily)",  group="⏱️ Higher Timeframes")

// ── EMA PERIOD INPUTS ───────────────────────────────────────────
int c1_fast = input.int(5,  "Cloud 1 Fast EMA", group="☁️ Cloud 1 — Short Term (5/12)")
int c1_slow = input.int(12, "Cloud 1 Slow EMA", group="☁️ Cloud 1 — Short Term (5/12)")

int c2_fast = input.int(34, "Cloud 2 Fast EMA", group="☁️ Cloud 2 — Macro Bias (34/50)")
int c2_slow = input.int(50, "Cloud 2 Slow EMA", group="☁️ Cloud 2 — Macro Bias (34/50)")

int c3_fast = input.int(8,  "Cloud 3 Fast EMA", group="☁️ Cloud 3 — Pullback (8/9)")
int c3_slow = input.int(9,  "Cloud 3 Slow EMA", group="☁️ Cloud 3 — Pullback (8/9)")

int c4_fast = input.int(20, "Cloud 4 Fast EMA", group="☁️ Cloud 4 — Swing (20/21)")
int c4_slow = input.int(21, "Cloud 4 Slow EMA", group="☁️ Cloud 4 — Swing (20/21)")

// ── FILTER & DISPLAY SETTINGS ───────────────────────────────────
bool require_close  = input.bool(true,  "Require candle CLOSE above/below cloud",        group="🔔 Alert Settings")
bool filter_mid_c2  = input.bool(true,  "Filter: require 1H Cloud 2 (34/50) bullish",    group="🔔 Alert Settings")
bool filter_high_c2 = input.bool(true,  "Filter: require Daily Cloud 2 (34/50) bullish", group="🔔 Alert Settings")
bool filter_mid_c4  = input.bool(false, "Filter: require 1H Cloud 4 (20/21) bullish",    group="🔔 Alert Settings")
bool show_partial   = input.bool(true,  "Show PARTIAL signals (only 1 HTF agrees)",      group="🔔 Alert Settings")
bool show_htf_table = input.bool(true,  "Show HTF Status Table on chart",                group="🔔 Alert Settings")

// ── HELPER FUNCTIONS (must be at top level in Pine v6) ──────────
f_bg(bool bull)  => bull ? color.new(color.green, 60) : color.new(color.red, 60)
f_txt(bool bull) => bull ? "🟢" : "🔴"

// ── CURRENT TF EMA CALCULATIONS ─────────────────────────────────
float ema_c1_fast = ta.ema(close, c1_fast)
float ema_c1_slow = ta.ema(close, c1_slow)
float ema_c2_fast = ta.ema(close, c2_fast)
float ema_c2_slow = ta.ema(close, c2_slow)
float ema_c3_fast = ta.ema(close, c3_fast)
float ema_c3_slow = ta.ema(close, c3_slow)
float ema_c4_fast = ta.ema(close, c4_fast)
float ema_c4_slow = ta.ema(close, c4_slow)

// Cloud tops, bottoms, direction
float c1_top = math.max(ema_c1_fast, ema_c1_slow)
float c1_bot = math.min(ema_c1_fast, ema_c1_slow)
bool  c1_bull = ema_c1_fast > ema_c1_slow

float c2_top = math.max(ema_c2_fast, ema_c2_slow)
float c2_bot = math.min(ema_c2_fast, ema_c2_slow)
bool  c2_bull = ema_c2_fast > ema_c2_slow

float c3_top = math.max(ema_c3_fast, ema_c3_slow)
bool  c3_bull = ema_c3_fast > ema_c3_slow

float c4_top = math.max(ema_c4_fast, ema_c4_slow)
float c4_bot = math.min(ema_c4_fast, ema_c4_slow)
bool  c4_bull = ema_c4_fast > ema_c4_slow

// ── HIGHER TIMEFRAME PULLS ──────────────────────────────────────
// In Pine v6 tuples from request.security must be declared inline like this
// Do NOT pre-declare the variables — declare and assign in one statement

float mid_c1f = request.security(syminfo.tickerid, tf_mid, ta.ema(close, c1_fast), lookahead=barmerge.lookahead_off)
float mid_c1s = request.security(syminfo.tickerid, tf_mid, ta.ema(close, c1_slow), lookahead=barmerge.lookahead_off)
float mid_c2f = request.security(syminfo.tickerid, tf_mid, ta.ema(close, c2_fast), lookahead=barmerge.lookahead_off)
float mid_c2s = request.security(syminfo.tickerid, tf_mid, ta.ema(close, c2_slow), lookahead=barmerge.lookahead_off)
float mid_c4f = request.security(syminfo.tickerid, tf_mid, ta.ema(close, c4_fast), lookahead=barmerge.lookahead_off)
float mid_c4s = request.security(syminfo.tickerid, tf_mid, ta.ema(close, c4_slow), lookahead=barmerge.lookahead_off)

float hi_c2f = request.security(syminfo.tickerid, tf_high, ta.ema(close, c2_fast), lookahead=barmerge.lookahead_off)
float hi_c2s = request.security(syminfo.tickerid, tf_high, ta.ema(close, c2_slow), lookahead=barmerge.lookahead_off)
float hi_c4f = request.security(syminfo.tickerid, tf_high, ta.ema(close, c4_fast), lookahead=barmerge.lookahead_off)
float hi_c4s = request.security(syminfo.tickerid, tf_high, ta.ema(close, c4_slow), lookahead=barmerge.lookahead_off)

// HTF cloud direction
bool mid_c1_bull = mid_c1f > mid_c1s
bool mid_c2_bull = mid_c2f > mid_c2s
bool mid_c4_bull = mid_c4f > mid_c4s
bool hi_c2_bull  = hi_c2f  > hi_c2s
bool hi_c4_bull  = hi_c4f  > hi_c4s

// ── HTF FILTER LOGIC ────────────────────────────────────────────
int  htf_bull_count   = (mid_c2_bull ? 1 : 0) + (hi_c2_bull ? 1 : 0)
bool htf_full_confirm = (not filter_mid_c2 or mid_c2_bull) and (not filter_high_c2 or hi_c2_bull) and (not filter_mid_c4 or mid_c4_bull)
bool htf_partial      = htf_bull_count >= 1

// ── CLOUD PLOTS ─────────────────────────────────────────────────
p1a = plot(ema_c1_fast, color=color.new(color.green, 100), title="C1 Fast")
p1b = plot(ema_c1_slow, color=color.new(color.green, 100), title="C1 Slow")
fill(p1a, p1b, color=c1_bull ? color.new(color.green, 80) : color.new(color.red, 80), title="Cloud 1")

p2a = plot(ema_c2_fast, color=color.new(color.blue, 100), title="C2 Fast")
p2b = plot(ema_c2_slow, color=color.new(color.blue, 100), title="C2 Slow")
fill(p2a, p2b, color=c2_bull ? color.new(color.blue, 75) : color.new(color.orange, 75), title="Cloud 2")

p3a = plot(ema_c3_fast, color=color.new(color.yellow, 100), title="C3 Fast")
p3b = plot(ema_c3_slow, color=color.new(color.yellow, 100), title="C3 Slow")
fill(p3a, p3b, color=c3_bull ? color.new(color.yellow, 80) : color.new(color.red, 80), title="Cloud 3")

p4a = plot(ema_c4_fast, color=color.new(color.teal, 100), title="C4 Fast")
p4b = plot(ema_c4_slow, color=color.new(color.teal, 100), title="C4 Slow")
fill(p4a, p4b, color=c4_bull ? color.new(color.teal, 80) : color.new(color.red, 80), title="Cloud 4")

// ── SIGNAL LOGIC ────────────────────────────────────────────────
float src_bull = require_close ? close : high
float src_bear = require_close ? close : low

bool c1_reclaim   = src_bull > c1_top and src_bull[1] <= c1_top[1]
bool c1_breakdown = src_bear < c1_bot and src_bear[1] >= c1_bot[1]

bool c2_reclaim   = src_bull > c2_top and src_bull[1] <= c2_top[1]
bool c2_breakdown = src_bear < c2_bot and src_bear[1] >= c2_bot[1]
bool c2_flip_bull = c2_bull and not c2_bull[1]
bool c2_flip_bear = not c2_bull and c2_bull[1]

bool c3_bounce    = low <= c3_top and close > c3_top

bool c4_reclaim   = src_bull > c4_top and src_bull[1] <= c4_top[1]
bool c4_flip_bull = c4_bull and not c4_bull[1]

bool all_bull_stack    = c1_bull and c2_bull and c3_bull and c4_bull and close > c1_top and close > c2_top and close > c3_top and close > c4_top
bool stack_just_formed = all_bull_stack and not all_bull_stack[1]

// ── MTF CONFIRMED SIGNALS ───────────────────────────────────────
bool confirmed_c1_reclaim = c1_reclaim      and htf_full_confirm
bool partial_c1_reclaim   = c1_reclaim      and htf_partial and not htf_full_confirm
bool confirmed_c2_reclaim = c2_reclaim      and htf_full_confirm
bool partial_c2_reclaim   = c2_reclaim      and htf_partial and not htf_full_confirm
bool confirmed_c2_flip    = c2_flip_bull    and htf_full_confirm
bool partial_c2_flip      = c2_flip_bull    and htf_partial and not htf_full_confirm
bool confirmed_c3_bounce  = c3_bounce       and htf_full_confirm
bool partial_c3_bounce    = c3_bounce       and htf_partial and not htf_full_confirm
bool confirmed_c4_reclaim = c4_reclaim      and htf_full_confirm
bool confirmed_stack      = stack_just_formed and htf_full_confirm
bool partial_stack        = stack_just_formed and htf_partial and not htf_full_confirm

// ── CHART LABELS ────────────────────────────────────────────────
if confirmed_c1_reclaim
    label.new(bar_index, low, "✅ C1 Reclaim\n1H+D confirmed", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)

if confirmed_c2_reclaim
    label.new(bar_index, low, "✅ C2 RECLAIM ★\n1H+D confirmed", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)

if confirmed_c2_flip
    label.new(bar_index, low, "✅ C2 Flipped GREEN\n1H+D confirmed", color=color.navy, textcolor=color.white, style=label.style_label_up, size=size.small)

if confirmed_c3_bounce
    label.new(bar_index, low, "✅ C3 Bounce\n1H+D confirmed", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)

if confirmed_c4_reclaim
    label.new(bar_index, low, "✅ C4 Reclaim\n1H+D confirmed", color=color.teal, textcolor=color.white, style=label.style_label_up, size=size.small)

if confirmed_stack
    label.new(bar_index, low, "🚀 FULL BULL STACK\n1H+D confirmed", color=color.purple, textcolor=color.white, style=label.style_label_up, size=size.large)

if show_partial and partial_c1_reclaim
    label.new(bar_index, low, "🟠 C1 Reclaim\nPartial HTF", color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.small)

if show_partial and partial_c2_reclaim
    label.new(bar_index, low, "🟠 C2 Reclaim\nPartial HTF", color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.normal)

if show_partial and partial_c2_flip
    label.new(bar_index, low, "🟠 C2 Flipped GREEN\nPartial HTF", color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.small)

if show_partial and partial_c3_bounce
    label.new(bar_index, low, "🟠 C3 Bounce\nPartial HTF", color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.small)

if show_partial and partial_stack
    label.new(bar_index, low, "🟠 BULL STACK\nPartial HTF", color=color.orange, textcolor=color.white, style=label.style_label_up, size=size.normal)

if c2_breakdown
    label.new(bar_index, high, "▼ C2 BREAK ★", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)

if c2_flip_bear
    label.new(bar_index, high, "☁️ C2 Flipped RED", color=color.maroon, textcolor=color.white, style=label.style_label_down, size=size.small)

if c1_breakdown
    label.new(bar_index, high, "▼ C1 Break", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)

// ── HTF STATUS TABLE ────────────────────────────────────────────
var table t = na
if show_htf_table and barstate.islast
    if na(t)
        t := table.new(position.top_right, 4, 5, border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)
    table.cell(t, 0, 0, "Cloud",    text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 1, 0, "Current",  text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 2, 0, tf_mid,     text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 3, 0, tf_high,    text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 0, 1, "C1 5/12",  text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 1, 1, f_txt(c1_bull),     bgcolor=f_bg(c1_bull),                          text_size=size.small)
    table.cell(t, 2, 1, f_txt(mid_c1_bull), bgcolor=f_bg(mid_c1_bull),                      text_size=size.small)
    table.cell(t, 3, 1, "—",                bgcolor=color.new(color.gray, 60),               text_size=size.small)
    table.cell(t, 0, 2, "C2 34/50", text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 1, 2, f_txt(c2_bull),     bgcolor=f_bg(c2_bull),                          text_size=size.small)
    table.cell(t, 2, 2, f_txt(mid_c2_bull), bgcolor=f_bg(mid_c2_bull),                      text_size=size.small)
    table.cell(t, 3, 2, f_txt(hi_c2_bull),  bgcolor=f_bg(hi_c2_bull),                       text_size=size.small)
    table.cell(t, 0, 3, "C3 8/9",   text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 1, 3, f_txt(c3_bull),     bgcolor=f_bg(c3_bull),                          text_size=size.small)
    table.cell(t, 2, 3, "—",                bgcolor=color.new(color.gray, 60),               text_size=size.small)
    table.cell(t, 3, 3, "—",                bgcolor=color.new(color.gray, 60),               text_size=size.small)
    table.cell(t, 0, 4, "C4 20/21", text_color=color.white, bgcolor=color.gray,              text_size=size.small)
    table.cell(t, 1, 4, f_txt(c4_bull),     bgcolor=f_bg(c4_bull),                          text_size=size.small)
    table.cell(t, 2, 4, f_txt(mid_c4_bull), bgcolor=f_bg(mid_c4_bull),                      text_size=size.small)
    table.cell(t, 3, 4, f_txt(hi_c4_bull),  bgcolor=f_bg(hi_c4_bull),                       text_size=size.small)

// ── ALERT CONDITIONS ────────────────────────────────────────────
alertcondition(confirmed_c2_reclaim,  "✅ C2 (34/50) Reclaim — CONFIRMED (All TFs)",    "C2 reclaim confirmed on 1H + Daily — HIGH CONVICTION bullish entry")
alertcondition(partial_c2_reclaim,    "🟠 C2 (34/50) Reclaim — PARTIAL (1 HTF agrees)", "C2 reclaim — partial HTF confirmation, trade with caution")
alertcondition(confirmed_c1_reclaim,  "✅ C1 (5/12) Reclaim — CONFIRMED (All TFs)",     "C1 reclaim confirmed on higher timeframes — bullish momentum entry")
alertcondition(partial_c1_reclaim,    "🟠 C1 (5/12) Reclaim — PARTIAL (1 HTF agrees)",  "C1 reclaim with partial HTF confirmation")
alertcondition(confirmed_c2_flip,     "✅ C2 Flipped GREEN — CONFIRMED (All TFs)",       "Cloud 2 flipped bullish AND higher timeframes agree — strong trend reversal")
alertcondition(partial_c2_flip,       "🟠 C2 Flipped GREEN — PARTIAL",                  "Cloud 2 flipped green but only partial HTF confirmation")
alertcondition(confirmed_c3_bounce,   "✅ C3 (8/9) Bounce — CONFIRMED (All TFs)",        "Pullback bounce off C3 with HTF confirmation — low risk entry")
alertcondition(confirmed_c4_reclaim,  "✅ C4 (20/21) Reclaim — CONFIRMED (All TFs)",    "Swing reclaim of C4 with HTF confirmation — 30DTE entry signal")
alertcondition(confirmed_stack,       "🚀 FULL BULL STACK — CONFIRMED ALL TFs",          "All 4 clouds green + price above all + 1H and Daily agree — HIGHEST conviction setup")
alertcondition(partial_stack,         "🟠 BULL STACK — PARTIAL HTF",                    "Full stack formed but only partial higher TF confirmation")
alertcondition(c2_breakdown,          "❌ C2 (34/50) Breakdown — Bearish",               "Price broke below Cloud 2 (34/50) — bearish signal, avoid calls")
alertcondition(c2_flip_bear,          "❌ C2 Flipped RED — Trend Reversal Down",         "Cloud 2 flipped bearish — macro trend turning down")
alertcondition(c1_breakdown,          "❌ C1 (5/12) Breakdown — Bearish",                "Price broke below Cloud 1 — short term momentum turned bearish")
````
