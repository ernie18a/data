# Timeframe Direction

- url: https://www.tradingview.com/script/zF3Daq8B-Timeframe-Direction/
- type: indicator
- pine_id: PUB;1b7750f0bab04bb3bea0284b57235c40
- version: 1.0

## Description

This indicator automatically marks supply and demand zones across three timeframes — 1H, 4H, and Daily — and shows the trend bias (Buy / Sell / Flat) for each, all on a single chart.
Zone detection (classic method)
Zones are formed using the textbook supply/demand pattern: a small consolidation base (1–3 candles with tight bodies) followed by a strong departure candle measured against ATR. A bullish leg-out creates a green DEMAND zone; a bearish leg-out creates a red SUPPLY zone. Each zone is labeled with its source timeframe (1H, 4H, 1D), so you can instantly see which zones carry more weight.
Multi-timeframe trend bias
A corner table reads the EMA relationship (fast vs slow) on each timeframe and reports the directional bias as BUY, SELL, or FLAT — giving you 1H, 4H, and Daily context at a glance for top-down alignment.
Key features

Classic consolidation-plus-impulse zone logic, not just raw pivots
Simultaneous 1H, 4H, and Daily zones, each labeled
EMA-slope trend bias table for all three timeframes
Optional automatic removal of zones once price mitigates (returns into) them
Adjustable base-candle sensitivity, ATR leg multiple, EMA lengths, colors, and zone extension
Built-in alerts for 1H bias flips to Buy or Sell

How to use it
Look for trade setups where the lower-timeframe price reaches a higher-timeframe zone while the trend bias agrees — for example, price tapping a 4H/Daily demand zone while the 1H bias turns BUY. Tune the base body % and ATR multiple to match the volatility of your instrument.
This tool is for educational and analytical purposes only and is not financial advice. Always combine it with your own risk management.

## Source Code

````pine
//@version=6
indicator("Timeframe Direction", shorttitle="TF Panel", overlay=true)

// ═══════════════════════════════════════════════════════
//  HOW DIRECTION IS DETERMINED
//  EMA 21 vs EMA 50 on each timeframe:
//  Price > EMA21 > EMA50  →  BULLISH
//  Price < EMA21 < EMA50  →  BEARISH
//  Anything in between    →  RANGING
// ═══════════════════════════════════════════════════════

i_ema_fast = input.int(21, "Fast EMA", minval=5,  maxval=100, group="Settings")
i_ema_slow = input.int(50, "Slow EMA", minval=10, maxval=200, group="Settings")
i_pos      = input.string("Top Right", "Panel Position",
             options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Settings")

// ═══════════════════════════════════════════════════════
//  DIRECTION FUNCTION  — runs inside each TF via request.security
// ═══════════════════════════════════════════════════════
f_dir() =>
    e_fast = ta.ema(close, i_ema_fast)
    e_slow = ta.ema(close, i_ema_slow)
    if close > e_fast and e_fast > e_slow
        1         // BULLISH
    else if close < e_fast and e_fast < e_slow
        -1        // BEARISH
    else
        0         // RANGING

// ═══════════════════════════════════════════════════════
//  REQUEST EACH TIMEFRAME
// ═══════════════════════════════════════════════════════
w_val  = request.security(syminfo.tickerid, "W",   f_dir(), lookahead=barmerge.lookahead_off)
d_val  = request.security(syminfo.tickerid, "D",   f_dir(), lookahead=barmerge.lookahead_off)
h4_val = request.security(syminfo.tickerid, "240", f_dir(), lookahead=barmerge.lookahead_off)
h1_val = request.security(syminfo.tickerid, "60",  f_dir(), lookahead=barmerge.lookahead_off)
m15_val = request.security(syminfo.tickerid, "15", f_dir(), lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════
//  DISPLAY HELPERS
// ═══════════════════════════════════════════════════════
f_txt(v) => v ==  1 ? "BULLISH" : v == -1 ? "BEARISH" : "RANGING"
f_arr(v) => v ==  1 ? "  ▲  "   : v == -1 ? "  ▼  "   : "  ◆  "
f_col(v) => v ==  1 ? color.new(#00cc66, 0) : v == -1 ? color.new(#dd3333, 0) : color.new(#ccaa00, 0)
f_bgc(v) => v ==  1 ? color.new(#00cc66, 82) : v == -1 ? color.new(#dd3333, 82) : color.new(color.gray, 88)

// ═══════════════════════════════════════════════════════
//  ALIGNMENT COUNT  — how many TFs agree on one direction
// ═══════════════════════════════════════════════════════
bull_count = (w_val == 1 ? 1 : 0) + (d_val == 1 ? 1 : 0) + (h4_val == 1 ? 1 : 0) + (h1_val == 1 ? 1 : 0) + (m15_val == 1 ? 1 : 0)
bear_count = (w_val == -1 ? 1 : 0) + (d_val == -1 ? 1 : 0) + (h4_val == -1 ? 1 : 0) + (h1_val == -1 ? 1 : 0) + (m15_val == -1 ? 1 : 0)
align_val  = bull_count >= bear_count ? bull_count : -bear_count
align_txt  = bull_count > bear_count ? str.tostring(bull_count) + "/5 BULLISH" : bear_count > bull_count ? str.tostring(bear_count) + "/5 BEARISH" : "MIXED"
align_col  = bull_count > bear_count ? color.new(#00cc66, 0) : bear_count > bull_count ? color.new(#dd3333, 0) : color.new(#ccaa00, 0)

// ═══════════════════════════════════════════════════════
//  TABLE PANEL
// ═══════════════════════════════════════════════════════
pos = i_pos == "Top Right"    ? position.top_right    :
      i_pos == "Top Left"     ? position.top_left     :
      i_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table t = table.new(pos, 3, 7,
    bgcolor      = color.new(color.black, 50),
    border_width = 1,
    border_color = color.new(color.gray, 65),
    frame_width  = 2,
    frame_color  = color.new(color.gray, 50))

if barstate.islast

    // ── Header row ───────────────────────────────────
    hbg = color.new(#0a1628, 5)
    table.cell(t, 0, 0, " TIMEFRAME ",
        bgcolor=hbg, text_color=color.new(color.white, 20),
        text_size=size.small, text_halign=text.align_center)
    table.cell(t, 1, 0, " DIR ",
        bgcolor=hbg, text_color=color.new(color.white, 20),
        text_size=size.small, text_halign=text.align_center)
    table.cell(t, 2, 0, " STATUS ",
        bgcolor=hbg, text_color=color.new(color.white, 20),
        text_size=size.small, text_halign=text.align_center)

    // ── Weekly ───────────────────────────────────────
    bg = f_bgc(w_val)
    table.cell(t, 0, 1, " Weekly ", bgcolor=bg,
        text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 1, f_arr(w_val), bgcolor=bg,
        text_color=f_col(w_val), text_size=size.large, text_halign=text.align_center)
    table.cell(t, 2, 1, " " + f_txt(w_val) + " ", bgcolor=bg,
        text_color=f_col(w_val), text_size=size.normal, text_halign=text.align_left)

    // ── Daily ────────────────────────────────────────
    bg := f_bgc(d_val)
    table.cell(t, 0, 2, " Daily ", bgcolor=bg,
        text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 2, f_arr(d_val), bgcolor=bg,
        text_color=f_col(d_val), text_size=size.large, text_halign=text.align_center)
    table.cell(t, 2, 2, " " + f_txt(d_val) + " ", bgcolor=bg,
        text_color=f_col(d_val), text_size=size.normal, text_halign=text.align_left)

    // ── 4 Hour ───────────────────────────────────────
    bg := f_bgc(h4_val)
    table.cell(t, 0, 3, " 4 Hour ", bgcolor=bg,
        text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 3, f_arr(h4_val), bgcolor=bg,
        text_color=f_col(h4_val), text_size=size.large, text_halign=text.align_center)
    table.cell(t, 2, 3, " " + f_txt(h4_val) + " ", bgcolor=bg,
        text_color=f_col(h4_val), text_size=size.normal, text_halign=text.align_left)

    // ── 1 Hour ───────────────────────────────────────
    bg := f_bgc(h1_val)
    table.cell(t, 0, 4, " 1 Hour ", bgcolor=bg,
        text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 4, f_arr(h1_val), bgcolor=bg,
        text_color=f_col(h1_val), text_size=size.large, text_halign=text.align_center)
    table.cell(t, 2, 4, " " + f_txt(h1_val) + " ", bgcolor=bg,
        text_color=f_col(h1_val), text_size=size.normal, text_halign=text.align_left)

    // ── 15 Min ───────────────────────────────────────
    bg := f_bgc(m15_val)
    table.cell(t, 0, 5, " 15 Min ", bgcolor=bg,
        text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 5, f_arr(m15_val), bgcolor=bg,
        text_color=f_col(m15_val), text_size=size.large, text_halign=text.align_center)
    table.cell(t, 2, 5, " " + f_txt(m15_val) + " ", bgcolor=bg,
        text_color=f_col(m15_val), text_size=size.normal, text_halign=text.align_left)

    // ── Alignment summary row ────────────────────────
    abg = bull_count > bear_count ? color.new(#00cc66, 72) : bear_count > bull_count ? color.new(#dd3333, 72) : color.new(color.gray, 82)
    table.cell(t, 0, 6, " OVERALL ",
        bgcolor=abg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 6, bull_count > bear_count ? "  ▲  " : bear_count > bull_count ? "  ▼  " : "  ◆  ",
        bgcolor=abg, text_color=align_col, text_size=size.normal, text_halign=text.align_center)
    table.cell(t, 2, 6, " " + align_txt + " ",
        bgcolor=abg, text_color=align_col, text_size=size.small, text_halign=text.align_left)
````
