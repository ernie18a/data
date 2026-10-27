# Tarak_Strategy

- url: https://www.tradingview.com/script/VQ1DaCE0-Tarak-Strategy/
- type: indicator
- pine_id: PUB;00b2edbe7bfe489c99d77c939c3f596c
- version: 1.0

## Description

Liquidity Sweep
✅ HTF Delivery (15m, 30m, 1h FVG clean rejection)
✅ SMT Divergence (Smart Money rejection)
✅ Inverted FVG (Reversal confirmation)
✅ CISD (Candle In Same Direction)
✅ Clear Liquidity Target

## Source Code

````pine

//@version=6
indicator("Multi-TF FVG + Directional Bias Monitor", overlay=true, max_lines_count=500, max_boxes_count=200, max_labels_count=300)

// ============================================================================
// INPUTS
// ============================================================================

show_daily_fvg     = input(true,  title="Show Daily FVG",               group="FVG Display")
show_4h_fvg        = input(true,  title="Show 4H FVG",                  group="FVG Display")
show_1h_fvg        = input(true,  title="Show 1H FVG",                  group="FVG Display")
show_ctf_fvg       = input(true,  title="Show Current TF FVG",          group="FVG Display")
fvg_box_width = input.int(50, title="FVG Box Width (bars)", group="FVG Display", minval=10, maxval=200)

show_bias          = input(true,  title="Show Bias SMAs",                group="Bias Analysis")
show_htf_structure = input(true,  title="Show HTF Background",           group="Bias Analysis")

entry_only_aligned = input(true,  title="Entry Only When All TF Aligned", group="Entry Rules")
minimum_fvg_size = input.int(20, title="Minimum FVG Size (pips)", group="Entry Rules", minval=1)

// ============================================================================
// MULTI-TIMEFRAME DATA REQUESTS
// ============================================================================

// Daily
d_high   = request.security(syminfo.tickerid, "D",   high)
d_high2  = request.security(syminfo.tickerid, "D",   high[2])
d_low    = request.security(syminfo.tickerid, "D",   low)
d_low2   = request.security(syminfo.tickerid, "D",   low[2])
d_close  = request.security(syminfo.tickerid, "D",   close)
d_sma20  = request.security(syminfo.tickerid, "D",   ta.sma(close, 20))
d_sma50  = request.security(syminfo.tickerid, "D",   ta.sma(close, 50))

// 4H
h4_high  = request.security(syminfo.tickerid, "240", high)
h4_high2 = request.security(syminfo.tickerid, "240", high[2])
h4_low   = request.security(syminfo.tickerid, "240", low)
h4_low2  = request.security(syminfo.tickerid, "240", low[2])
h4_close = request.security(syminfo.tickerid, "240", close)
h4_sma20 = request.security(syminfo.tickerid, "240", ta.sma(close, 20))
h4_sma50 = request.security(syminfo.tickerid, "240", ta.sma(close, 50))

// 1H
h1_high  = request.security(syminfo.tickerid, "60",  high)
h1_high2 = request.security(syminfo.tickerid, "60",  high[2])
h1_low   = request.security(syminfo.tickerid, "60",  low)
h1_low2  = request.security(syminfo.tickerid, "60",  low[2])
h1_close = request.security(syminfo.tickerid, "60",  close)
h1_sma20 = request.security(syminfo.tickerid, "60",  ta.sma(close, 20))
h1_sma50 = request.security(syminfo.tickerid, "60",  ta.sma(close, 50))

// Current Chart Timeframe
ctf_high  = high
ctf_high2 = high[2]
ctf_low   = low
ctf_low2  = low[2]

// ============================================================================
// FVG DETECTION
// Bullish FVG = current low > 2-bar-ago high  (price gapped UP)
// Bearish FVG = current high < 2-bar-ago low  (price gapped DOWN)
// ============================================================================

pip_value = syminfo.mintick * 10

// Daily FVGs
d_bull_fvg    = d_low   > d_high2 and (d_low   - d_high2) / pip_value >= minimum_fvg_size
d_bear_fvg    = d_high  < d_low2  and (d_low2  - d_high)  / pip_value >= minimum_fvg_size
d_bull_top    = d_low
d_bull_bottom = d_high2
d_bear_top    = d_low2
d_bear_bottom = d_high

// 4H FVGs
h4_bull_fvg    = h4_low  > h4_high2 and (h4_low  - h4_high2) / pip_value >= minimum_fvg_size
h4_bear_fvg    = h4_high < h4_low2  and (h4_low2 - h4_high)  / pip_value >= minimum_fvg_size
h4_bull_top    = h4_low
h4_bull_bottom = h4_high2
h4_bear_top    = h4_low2
h4_bear_bottom = h4_high

// 1H FVGs
h1_bull_fvg    = h1_low  > h1_high2 and (h1_low  - h1_high2) / pip_value >= minimum_fvg_size
h1_bear_fvg    = h1_high < h1_low2  and (h1_low2 - h1_high)  / pip_value >= minimum_fvg_size
h1_bull_top    = h1_low
h1_bull_bottom = h1_high2
h1_bear_top    = h1_low2
h1_bear_bottom = h1_high

// Current TF FVGs
ctf_bull_fvg    = ctf_low  > ctf_high2 and (ctf_low  - ctf_high2) / pip_value >= minimum_fvg_size
ctf_bear_fvg    = ctf_high < ctf_low2  and (ctf_low2 - ctf_high)  / pip_value >= minimum_fvg_size
ctf_bull_top    = ctf_low
ctf_bull_bottom = ctf_high2
ctf_bear_top    = ctf_low2
ctf_bear_bottom = ctf_high

// ============================================================================
// DIRECTIONAL BIAS
// ============================================================================

d_bullish  = d_close  > d_sma20  and d_sma20  > d_sma50
d_bearish  = d_close  < d_sma20  and d_sma20  < d_sma50
h4_bullish = h4_close > h4_sma20 and h4_sma20 > h4_sma50
h4_bearish = h4_close < h4_sma20 and h4_sma20 < h4_sma50
h1_bullish = h1_close > h1_sma20 and h1_sma20 > h1_sma50
h1_bearish = h1_close < h1_sma20 and h1_sma20 < h1_sma50

// ============================================================================
// ALIGNMENT & CONFLUENCE
// ============================================================================

all_tf_bullish    = d_bullish and h4_bullish and h1_bullish
all_tf_bearish    = d_bearish and h4_bearish and h1_bearish
bull_fvgs_present = d_bull_fvg or h4_bull_fvg or h1_bull_fvg or ctf_bull_fvg
bear_fvgs_present = d_bear_fvg or h4_bear_fvg or h1_bear_fvg or ctf_bear_fvg
bullish_alignment = all_tf_bullish and bull_fvgs_present
bearish_alignment = all_tf_bearish and bear_fvgs_present

// Price inside FVG zone checks
in_d_bull_fvg   = close >= d_bull_bottom   and close <= d_bull_top
in_d_bear_fvg   = close >= d_bear_bottom   and close <= d_bear_top
in_h4_bull_fvg  = close >= h4_bull_bottom  and close <= h4_bull_top
in_h4_bear_fvg  = close >= h4_bear_bottom  and close <= h4_bear_top
in_h1_bull_fvg  = close >= h1_bull_bottom  and close <= h1_bull_top
in_h1_bear_fvg  = close >= h1_bear_bottom  and close <= h1_bear_top
in_ctf_bull_fvg = close >= ctf_bull_bottom and close <= ctf_bull_top
in_ctf_bear_fvg = close >= ctf_bear_bottom and close <= ctf_bear_top

in_any_bull_fvg = in_d_bull_fvg or in_h4_bull_fvg or in_h1_bull_fvg or in_ctf_bull_fvg
in_any_bear_fvg = in_d_bear_fvg or in_h4_bear_fvg or in_h1_bear_fvg or in_ctf_bear_fvg
in_any_fvg      = in_any_bull_fvg or in_any_bear_fvg

// ============================================================================
// SIGNALS
// ============================================================================

bullish_signal = entry_only_aligned ? (bullish_alignment and in_any_bull_fvg) : (all_tf_bullish and in_any_bull_fvg)
bearish_signal = entry_only_aligned ? (bearish_alignment and in_any_bear_fvg) : (all_tf_bearish and in_any_bear_fvg)

// ============================================================================
// PLOTTING — SMAs (global scope, ternary used for visibility toggle)
// ============================================================================

plot(show_bias ? d_sma20  : na, title="Daily SMA 20", color=color.new(color.green,  40), linewidth=3)
plot(show_bias ? d_sma50  : na, title="Daily SMA 50", color=color.new(color.red,    40), linewidth=3)
plot(show_bias ? h4_sma20 : na, title="4H SMA 20",    color=color.new(color.lime,   50), linewidth=2)
plot(show_bias ? h4_sma50 : na, title="4H SMA 50",    color=color.new(color.orange, 50), linewidth=2)

// ============================================================================
// BACKGROUND ZONES (global scope)
// ============================================================================

bgcolor(show_htf_structure and all_tf_bullish ? color.new(color.green, 92) : na, title="All TF Bullish Zone")
bgcolor(show_htf_structure and all_tf_bearish ? color.new(color.red,   92) : na, title="All TF Bearish Zone")

// ============================================================================
// FVG BOXES — Daily
// ============================================================================

if show_daily_fvg
    if d_bull_fvg
        box.new(left=bar_index - fvg_box_width, top=d_bull_top, right=bar_index, bottom=d_bull_bottom,
                bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 50), border_width=2)
        label.new(x=bar_index - fvg_box_width / 2, y=d_bull_top,
                  text="D-FVG ↑", color=color.new(color.green, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.small)
    if d_bear_fvg
        box.new(left=bar_index - fvg_box_width, top=d_bear_top, right=bar_index, bottom=d_bear_bottom,
                bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 50), border_width=2)
        label.new(x=bar_index - fvg_box_width / 2, y=d_bear_bottom,
                  text="D-FVG ↓", color=color.new(color.red, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.small)

// ============================================================================
// FVG BOXES — 4H
// ============================================================================

if show_4h_fvg
    if h4_bull_fvg
        box.new(left=bar_index - fvg_box_width, top=h4_bull_top, right=bar_index, bottom=h4_bull_bottom,
                bgcolor=color.new(color.lime, 75), border_color=color.new(color.lime, 40), border_width=1)
        label.new(x=bar_index - fvg_box_width / 2, y=h4_bull_top,
                  text="4H ↑", color=color.new(color.lime, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.tiny)
    if h4_bear_fvg
        box.new(left=bar_index - fvg_box_width, top=h4_bear_top, right=bar_index, bottom=h4_bear_bottom,
                bgcolor=color.new(color.orange, 75), border_color=color.new(color.orange, 40), border_width=1)
        label.new(x=bar_index - fvg_box_width / 2, y=h4_bear_bottom,
                  text="4H ↓", color=color.new(color.orange, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.tiny)

// ============================================================================
// FVG BOXES — 1H
// ============================================================================

if show_1h_fvg
    if h1_bull_fvg
        box.new(left=bar_index - fvg_box_width, top=h1_bull_top, right=bar_index, bottom=h1_bull_bottom,
                bgcolor=color.new(color.aqua, 70), border_color=color.new(color.aqua, 30), border_width=1)
        label.new(x=bar_index - fvg_box_width / 2, y=h1_bull_top,
                  text="1H ↑", color=color.new(color.aqua, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.tiny)
    if h1_bear_fvg
        box.new(left=bar_index - fvg_box_width, top=h1_bear_top, right=bar_index, bottom=h1_bear_bottom,
                bgcolor=color.new(color.yellow, 70), border_color=color.new(color.yellow, 30), border_width=1)
        label.new(x=bar_index - fvg_box_width / 2, y=h1_bear_bottom,
                  text="1H ↓", color=color.new(color.yellow, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.tiny)

// ============================================================================
// FVG BOXES — Current TF
// ============================================================================

if show_ctf_fvg
    if ctf_bull_fvg
        box.new(left=bar_index - 10, top=ctf_bull_top, right=bar_index, bottom=ctf_bull_bottom,
                bgcolor=color.new(color.blue, 60), border_color=color.new(color.blue, 20), border_width=1)
        label.new(x=bar_index - 5, y=ctf_bull_top,
                  text="CTF ↑", color=color.new(color.blue, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.tiny)
    if ctf_bear_fvg
        box.new(left=bar_index - 10, top=ctf_bear_top, right=bar_index, bottom=ctf_bear_bottom,
                bgcolor=color.new(color.purple, 60), border_color=color.new(color.purple, 20), border_width=1)
        label.new(x=bar_index - 5, y=ctf_bear_bottom,
                  text="CTF ↓", color=color.new(color.purple, 0), textcolor=color.white,
                  style=label.style_label_center, size=size.tiny)

// ============================================================================
// ENTRY SIGNALS
// ============================================================================

plotshape(bullish_signal, style=shape.arrowup,   location=location.belowbar,
          color=color.new(color.lime, 0), size=size.large, title="Bullish Entry Signal")
plotshape(bearish_signal, style=shape.arrowdown, location=location.abovebar,
          color=color.new(color.red,  0), size=size.large, title="Bearish Entry Signal")

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(bullish_alignment, title="Bullish Multi-TF Alignment", message="BULLISH: All TF aligned + Bullish FVGs present")
alertcondition(bearish_alignment, title="Bearish Multi-TF Alignment", message="BEARISH: All TF aligned + Bearish FVGs present")
alertcondition(bullish_signal,    title="Bullish Entry Signal",        message="BULLISH ENTRY: Price in FVG + All TF Aligned")
alertcondition(bearish_signal,    title="Bearish Entry Signal",        message="BEARISH ENTRY: Price in FVG + All TF Aligned")

// ============================================================================
// DASHBOARD TABLE
// ============================================================================

var table dash = table.new(position=position.top_right, columns=3, rows=12,
                            bgcolor=color.new(color.black, 80), border_color=color.gray, border_width=1)

col_bull = color.lime
col_bear = color.red
col_neut = color.gray
col_hdr  = color.new(color.blue, 60)
col_sec  = color.new(color.navy, 40)

// Row 0 — Header
table.cell(table_id=dash, column=0, row=0, text="TIMEFRAME", text_color=color.white, text_size=size.small, bgcolor=col_hdr, text_halign=text.align_center)
table.cell(table_id=dash, column=1, row=0, text="BIAS",      text_color=color.white, text_size=size.small, bgcolor=col_hdr, text_halign=text.align_center)
table.cell(table_id=dash, column=2, row=0, text="FVG",       text_color=color.white, text_size=size.small, bgcolor=col_hdr, text_halign=text.align_center)

// Row 1 — Daily
d_bias_txt = d_bullish  ? "BULL ↑" : d_bearish  ? "BEAR ↓" : "NEUTRAL"
d_bias_col = d_bullish  ? col_bull  : d_bearish  ? col_bear  : col_neut
d_fvg_txt  = d_bull_fvg ? "BULL ↑" : d_bear_fvg ? "BEAR ↓" : "—"
d_fvg_col  = d_bull_fvg ? col_bull  : d_bear_fvg ? col_bear  : col_neut
table.cell(table_id=dash, column=0, row=1, text="DAILY",    text_color=color.white, text_size=size.small)
table.cell(table_id=dash, column=1, row=1, text=d_bias_txt, text_color=d_bias_col,  text_size=size.small, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=1, text=d_fvg_txt,  text_color=d_fvg_col,   text_size=size.small, text_halign=text.align_right)

// Row 2 — 4H
h4_bias_txt = h4_bullish  ? "BULL ↑" : h4_bearish  ? "BEAR ↓" : "NEUTRAL"
h4_bias_col = h4_bullish  ? col_bull  : h4_bearish  ? col_bear  : col_neut
h4_fvg_txt  = h4_bull_fvg ? "BULL ↑" : h4_bear_fvg ? "BEAR ↓" : "—"
h4_fvg_col  = h4_bull_fvg ? col_bull  : h4_bear_fvg ? col_bear  : col_neut
table.cell(table_id=dash, column=0, row=2, text="4H",        text_color=color.white, text_size=size.small)
table.cell(table_id=dash, column=1, row=2, text=h4_bias_txt, text_color=h4_bias_col, text_size=size.small, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=2, text=h4_fvg_txt,  text_color=h4_fvg_col,  text_size=size.small, text_halign=text.align_right)

// Row 3 — 1H
h1_bias_txt = h1_bullish  ? "BULL ↑" : h1_bearish  ? "BEAR ↓" : "NEUTRAL"
h1_bias_col = h1_bullish  ? col_bull  : h1_bearish  ? col_bear  : col_neut
h1_fvg_txt  = h1_bull_fvg ? "BULL ↑" : h1_bear_fvg ? "BEAR ↓" : "—"
h1_fvg_col  = h1_bull_fvg ? col_bull  : h1_bear_fvg ? col_bear  : col_neut
table.cell(table_id=dash, column=0, row=3, text="1H",        text_color=color.white, text_size=size.small)
table.cell(table_id=dash, column=1, row=3, text=h1_bias_txt, text_color=h1_bias_col, text_size=size.small, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=3, text=h1_fvg_txt,  text_color=h1_fvg_col,  text_size=size.small, text_halign=text.align_right)

// Row 4 — Current TF
ctf_fvg_txt = ctf_bull_fvg ? "BULL ↑" : ctf_bear_fvg ? "BEAR ↓" : "—"
ctf_fvg_col = ctf_bull_fvg ? col_bull  : ctf_bear_fvg ? col_bear  : col_neut
table.cell(table_id=dash, column=0, row=4, text="CURR TF",   text_color=color.white, text_size=size.small)
table.cell(table_id=dash, column=1, row=4, text="—",         text_color=col_neut,    text_size=size.small, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=4, text=ctf_fvg_txt, text_color=ctf_fvg_col, text_size=size.small, text_halign=text.align_right)

// Row 5 — Separator
table.cell(table_id=dash, column=0, row=5, text="", bgcolor=color.new(color.gray, 80))
table.cell(table_id=dash, column=1, row=5, text="", bgcolor=color.new(color.gray, 80))
table.cell(table_id=dash, column=2, row=5, text="", bgcolor=color.new(color.gray, 80))

// Row 6 — Price in FVG
fvg_status_txt = in_any_fvg ? "YES" : "NO"
fvg_status_col = in_any_fvg ? col_bull : color.orange
table.cell(table_id=dash, column=0, row=6, text="PRICE IN FVG", text_color=color.white,    text_size=size.small, bgcolor=col_sec)
table.cell(table_id=dash, column=1, row=6, text=fvg_status_txt, text_color=fvg_status_col, text_size=size.small, bgcolor=col_sec, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=6, text="",             text_color=color.white,     text_size=size.small, bgcolor=col_sec)

// Row 7 — TF Alignment
align_txt = all_tf_bullish ? "BULL ↑↑↑" : all_tf_bearish ? "BEAR ↓↓↓" : "MIXED"
align_col = all_tf_bullish ? col_bull    : all_tf_bearish ? col_bear    : color.orange
table.cell(table_id=dash, column=0, row=7, text="TF ALIGNMENT", text_color=color.white, text_size=size.small, bgcolor=col_sec)
table.cell(table_id=dash, column=1, row=7, text=align_txt,      text_color=align_col,   text_size=size.small, bgcolor=col_sec, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=7, text="",             text_color=color.white,  text_size=size.small, bgcolor=col_sec)

// Row 8 — Entry Ready
entry_txt = bullish_signal ? "BUY"    : bearish_signal ? "SELL"   : "WAITING"
entry_col = bullish_signal ? col_bull : bearish_signal ? col_bear : color.orange
table.cell(table_id=dash, column=0, row=8, text="ENTRY READY", text_color=color.white, text_size=size.small, bgcolor=col_sec)
table.cell(table_id=dash, column=1, row=8, text=entry_txt,     text_color=entry_col,   text_size=size.small, bgcolor=col_sec, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=8, text="",            text_color=color.white,  text_size=size.small, bgcolor=col_sec)

// Row 9 — Signal Type
sig_txt = bullish_signal ? "BULLISH ENTRY" : bearish_signal ? "BEARISH ENTRY" : "—"
sig_col = bullish_signal ? col_bull        : bearish_signal ? col_bear        : col_neut
table.cell(table_id=dash, column=0, row=9, text="SIGNAL TYPE", text_color=color.white, text_size=size.small, bgcolor=col_sec)
table.cell(table_id=dash, column=1, row=9, text=sig_txt,       text_color=sig_col,     text_size=size.small, bgcolor=col_sec, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=9, text="",            text_color=color.white,  text_size=size.small, bgcolor=col_sec)

// Row 10 — Confidence
conf_tf_count = (d_bullish or d_bearish ? 1 : 0) + (h4_bullish or h4_bearish ? 1 : 0) + (h1_bullish or h1_bearish ? 1 : 0)
conf_txt = conf_tf_count == 3 and in_any_fvg ? "HIGH   ***" : conf_tf_count >= 2 and in_any_fvg ? "MEDIUM  **" : "LOW      *"
conf_col = conf_tf_count == 3 and in_any_fvg ? col_bull : conf_tf_count >= 2 and in_any_fvg ? color.yellow : color.orange
table.cell(table_id=dash, column=0, row=10, text="CONFIDENCE", text_color=color.white, text_size=size.small, bgcolor=col_sec)
table.cell(table_id=dash, column=1, row=10, text=conf_txt,     text_color=conf_col,    text_size=size.small, bgcolor=col_sec, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=10, text="",           text_color=color.white,  text_size=size.small, bgcolor=col_sec)

// Row 11 — Min FVG Size
table.cell(table_id=dash, column=0, row=11, text="MIN FVG SIZE",                            text_color=color.white, text_size=size.small, bgcolor=col_sec)
table.cell(table_id=dash, column=1, row=11, text=str.tostring(minimum_fvg_size) + " pips",  text_color=col_neut,    text_size=size.small, bgcolor=col_sec, text_halign=text.align_right)
table.cell(table_id=dash, column=2, row=11, text="",                                        text_color=color.white,  text_size=size.small, bgcolor=col_sec)
````
